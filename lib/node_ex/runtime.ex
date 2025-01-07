defmodule NodeEx.Runtime do
  @moduledoc """
  Runtime implementation for NodeRed.

  NodeRed POSTs json specification of the whole workspace to the server.
  It also pushes information via header, if it's a node reload, flow reload or complete reload.
  It is the task of the runtime to figure out, which flows have changed.
  Since the datastructure is not nested the easiest approach is to directly compare the two
  structure inside a converter elixir structure.
  """
  defstruct [:workspace, :client_pids_with_id, :flow_sup_pids, :node_pids]

  use GenServer

  alias NodeEx.Runtime.Evaluator
  alias NodeEx.Runtime.Workspace
  alias NodeEx.User
  alias NodeEx.Utils

  @timeout :infinity
  @client_id "__server__"
  @anonymous_client_id "__anonymous__"

  @type t :: %{
          workspace: Workspace.t(),
          client_pids_with_id: %{pid() => Workspace.client_id()},
          flow_sup_pids: list(pid()),
          node_pids: %{Workspace.Node.id() => pid()}
        }

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Register a new client.
  """
  @spec register_client(pid(), User.t()) :: {Workspace.t(), Workspace.client_id()}
  def register_client(client_pid, user) do
    GenServer.call(__MODULE__, {:register_client, client_pid, user}, @timeout)
  end

  @doc """
  Subscribes to runtimes messages.
  """
  @spec subscribe() :: :ok | {:error, term()}
  def subscribe() do
    Phoenix.PubSub.subscribe(NodeEx.PubSub, "runtime")
  end

  @doc """
  Returns the current workspace structure.
  """
  @spec get_workspace() :: Workspace.t()
  def get_workspace() do
    GenServer.call(__MODULE__, :get_workspace, @timeout)
  end

  @doc """
  """
  @spec get_node_pid(Workspace.Node.id()) :: {:ok, pid()} | :error
  def get_node_pid(id) do
    GenServer.call(__MODULE__, {:get_node_pid, id}, @timeout)
  end

  @doc """
  Adds new flow to workspace.
  """
  @spec insert_flow(map()) :: :ok
  def insert_flow(flow) do
    GenServer.cast(__MODULE__, {:insert_flow, self(), flow})
  end

  @doc """
  Adds new node to flow.
  """
  @spec insert_node(Flow.id(), map()) :: :ok
  def insert_node(flow_id, node) do
    GenServer.cast(__MODULE__, {:insert_node, self(), flow_id, node})
  end

  @doc """
  """
  @spec deploy_flows(map(), Workspace.deployment_type()) :: :ok
  def deploy_flows(json_flows, deployment_type) do
    GenServer.cast(__MODULE__, {:deploy_flows, self(), json_flows, deployment_type})
  end

  ## Callback

  @impl true
  def init(_opts) do
    state = %__MODULE__{
      workspace: Workspace.new(),
      client_pids_with_id: %{},
      flow_sup_pids: []
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:register_client, client_pid, user}, _from, state) do
    {state, client_id} =
      if client_id = state.client_pids_with_id[client_pid] do
        {state, client_id}
      else
        Process.monitor(client_pid)
        client_id = Utils.random_id()
        state = handle_operation(state, {:client_join, client_id, user})
        state = put_in(state.client_pids_with_id[client_pid], client_id)
        {state, client_id}
      end

    {:reply, {state.workspace, client_id}, state}
  end

  @impl true
  def handle_call(:get_workspace, _from, state) do
    {:reply, state.workspace, state}
  end

  def handle_call({:get_node_pid, id}, _from, state) do
    case Map.get(state.node_pids, id, nil) do
      nil ->
        {:reply, :error, state}

      pid ->
        {:reply, {:ok, pid}, state}
    end
  end

  @impl true
  def handle_cast({:insert_flow, client_pid, flow}, state) do
    client_id = client_id(state, client_pid)
    # TODO: what happens if key id is not given?
    id = Map.get(flow, "id")
    operation = {:insert_flow, client_id, id, flow}
    {:noreply, handle_operation(state, operation)}
  end

  def handle_cast({:insert_node, client_pid, flow_id, node}, state) do
    client_id = client_id(state, client_pid)
    # TODO: what happens if key id is not given?
    node_id = Map.get(node, "id")
    operation = {:insert_node, client_id, flow_id, node_id, node}
    {:noreply, handle_operation(state, operation)}
  end

  def handle_cast({:deploy_flows, client_pid, json_flows, deployment_type}, state) do
    client_id = client_id(state, client_pid)
    operation = {:deploy_flows, client_id, json_flows, deployment_type}
    {:noreply, handle_operation(state, operation)}
  end

  @impl true
  def handle_info({:DOWN, _, :process, pid, _}, state) do
    state =
      if client_id = state.client_pids_with_id[pid] do
        handle_operation(state, {:client_leave, client_id})
      else
        state
      end

    {:noreply, state}
  end

  defp handle_operation(state, operation) do
    broadcast_operation(operation)

    case Workspace.apply_operation(state.workspace, operation) do
      {:ok, new_workspace, actions} ->
        %{state | workspace: new_workspace}
        |> after_operation(state, operation)
        |> handle_actions(actions)

      :error ->
        state
    end
  end

  defp after_operation(state, _prev_state, _operation), do: state

  defp handle_actions(state, actions) do
    Enum.reduce(actions, state, &handle_action(&2, &1))
  end

  defp handle_action(state, {:deploy, _deployment_type}) do
    # TODO use different deployment stratgies
    IEx.Helpers.respawn()

    Enum.each(state.flow_sup_pids, fn flow_sup_pid ->
      :ok = DynamicSupervisor.terminate_child(NodeEx.Runtime.FlowsSupervisor, flow_sup_pid)
    end)

    %{flow_sup_pids: flow_sup_pids, node_pids: node_pids} =
      Enum.map(state.workspace.flows, fn {_flow_id, flow} ->
        {:ok, flow_sup_pid} =
          DynamicSupervisor.start_child(
            NodeEx.Runtime.FlowsSupervisor,
            {DynamicSupervisor, name: NodeEx.Runtime.FlowSupervisor, strategy: :one_for_one}
          )

        node_pids =
          Enum.map(flow.nodes, fn
            {node_id, {:not_loaded, module}} ->
              IO.inspect(module, label: "Not loaded")
              {node_id, nil}

            {node_id, node} ->
              {:ok, node_pid} =
                DynamicSupervisor.start_child(flow_sup_pid, {node.__struct__, node})
                |> IO.inspect(label: "Start node")

              {node_id, node_pid}
          end)
          |> Map.new()

        {flow_sup_pid, node_pids}
      end)
      |> Enum.reduce(%{flow_sup_pids: [], node_pids: %{}}, fn {flow_sup_pid, flow_node_pids},
                                                              acc ->
        %{
          acc
          | flow_sup_pids: [flow_sup_pid | acc.flow_sup_pids],
            node_pids: Map.merge(acc.node_pids, flow_node_pids)
        }
      end)

    %{state | flow_sup_pids: flow_sup_pids, node_pids: node_pids}
  end

  defp handle_action(state, _action), do: state

  defp broadcast_operation(operation) do
    broadcast_message({:operation, operation})
  end

  defp broadcast_error(error) do
    broadcast_message({:error, error})
  end

  defp broadcast_message(message) do
    Phoenix.PubSub.broadcast(NodeEx.PubSub, "runtime", message)
  end

  defp client_id(state, client_pid) do
    state.client_pids_with_id[client_pid] || @anonymous_client_id
  end
end
