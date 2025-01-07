defmodule NodeExWeb.Channel.CommsSocket do
  use NodeExWeb, :verified_routes
  @behaviour WebSock

  @hb_interval 15000

  alias NodeExWeb.Channel.Server
  alias NodeEx.Runtime
  alias NodeEx.User

  @impl true
  def init(_params) do
    time_stamp = :os.system_time(:millisecond)

    Process.send_after(self(), {:hb, time_stamp}, @hb_interval)

    :ok = Runtime.subscribe()
    {workspace, client_id} = Runtime.register_client(self(), User.new())

    {:ok, %{workspace: workspace, client_id: client_id}}
  end

  @impl true
  def handle_in({msg, _}, state) do
    case Jason.decode(msg) do
      {:ok, json} -> handle_msg(json)
      error -> IO.inspect(error)
    end

    {:ok, state}
  end

  defp handle_msg(%{"subscribe" => topic}) do
    :ok = Server.subscribe([topic])
  end

  defp handle_msg(%{"topic" => topic, "data" => data}) do
    Server.publish(topic, data)
  end

  defp handle_msg(msg) do
    IO.inspect(msg, label: "Last handle msg")
  end

  @impl true
  def handle_info({:push_event, topic, msg}, state) do
    data = [%{topic: topic, data: msg}] |> Jason.encode!()
    {:push, {:text, data}, state}
  end

  def handle_info({:operation, operation}, state) do
    {:ok, handle_operation(state, operation)}
  end

  def handle_info({:hb, time_stamp}, state) do
    Process.send_after(self(), {:hb, time_stamp}, @hb_interval)
    data = [%{topic: "hb", data: time_stamp}] |> Jason.encode!()
    {:push, {:text, data}, state}
  end

  def handle_info({:set_status, node, text}, state) do
    data =
      [%{topic: "status/#{node}", data: %{text: text, fill: "red", shape: "ring"}}]
      |> Jason.encode!()

    {:push, {:text, data}, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg, label: "handle_info")
    {:ok, state}
  end

  defp handle_operation(state, operation) do
    case Runtime.Workspace.apply_operation(state.workspace, operation) do
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

  defp handle_action(state, {:deploy, deployment_type}) do
    # TODO split this into different deployment actions
    push_event("notification/runtime-state", %{state: "stop", deploy: true})
    push_event("notification/runtime-state", %{state: "start", deploy: true})
    # TODO send current rev
    push_event("notification/runtime-deploy", %{revision: :new_rev})
    state
  end

  defp handle_action(state, _action), do: state

  defp push_event(topic, msg) do
    send(self(), {:push_event, topic, msg})
  end
end
