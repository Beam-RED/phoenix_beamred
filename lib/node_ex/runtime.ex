defmodule NodeEx.Runtime do
  @moduledoc """
  Runtime implementation for NodeRed.

  NodeRed POSTs json specification of the whole workspace to the server.
  It also pushes information via header, if it's a node reload, flow reload or complete reload.
  It is the task of the runtime to figure out, which flows have changed.
  Since the datastructure is not nested the easiest approach is to directly compare the two
  structure inside a converter elixir structure.
  """
  defstruct [:workspace, :client_pids_with_id]

  use GenServer

  alias NodeEx.Runtime.Workspace

  @timeout :ininity
  @client_id "__server__"
  @anonymous_client_id "__anonymous__"

  @type t :: %{
          workspace: Workspace.t(),
          client_pids_with_id: %{pid() => Workspace.client_id()}
        }

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  """
  @spec register_client(pid(), User.t()) :: {Workspace.t(), Workspace.client_id()}
  def register_client(client_pid, user) do
    GenServer.call(__MODULE__, {:register_client, client_pid, user}, @timeout)
  end

  @spec insert_flow(map()) :: :ok
  def insert_flow(flow) do
    GenServer.cast(__MODULE__, {:insert_flow, self(), flow})
  end

  ## Callback

  @impl true
  def init(_opts) do
    state = %__MODULE__{
      workspace: Workspace.new(),
      client_pids_with_id: %{}
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

    {:reply, {state.data, client_id}, state}
  end

  @impl true
  def handle_cast({:insert_flow, client_pid, flow}, state) do
    client_id = client_id(state, client_pid)
    # TODO: what happens if key id is not given?
    id = Map.get(flow, "id")
    operation = {:insert_flow, client_id, id, flow}
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
  end

  defp handle_operation(state, operation) do
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

  defp handle_actions(state, _action), do: state

  defp client_id(state, client_pid) do
    state.client_pids_with_id[client_pid] || @anonymous_client_id
  end
end
