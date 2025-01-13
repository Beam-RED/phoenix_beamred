defmodule BeamRED.Nodes.BeamSend do
  use NodeType,
    name: "beam-send",
    asset_path: "lib/beamred/nodes/beam_send"

  alias BeamRED.Runtime
  alias BeamRED.Runtime.Workspace

  @impl true
  def setup(node) do
    case Code.string_to_quoted(node.fields["msg"]) do
      {:ok, _} ->
        Runtime.set_node_status(node.flow_id, node.id, {"Valid", :green, :ring})

      {:error, _reason} ->
        Runtime.set_node_status(node.flow_id, node.id, {"Invalid Message", :red, :ring})
    end

    IO.inspect(node)

    {:ok,
     %{
       id: node.id,
       outputs: hd(node.outputs),
       action_type: node.fields["action_type"],
       message: node.fields["msg"]
     }}
  end

  @impl true
  def subscribe(node_id) do
    BeamRED.MQTT.Server.subscribe(["notification/node/#{node_id}"])
  end

  @impl true
  def handle_info({:publish, "notification/node/" <> node_id, "send"}, state) do
    IO.inspect(state, label: "Send")

    Enum.each(state.outputs, fn output ->
      {:ok, pid} = Runtime.get_node_pid(output)

      case state.action_type do
        "send" -> send(pid, state.message)
        "call" -> GenServer.call(pid, state.message)
        "cast" -> GenServer.cast(pid, state.message)
        # TODO implement this. it should call a function with arguments
        "trigger" -> send(pid, state.message)
      end
    end)

    {:noreply, state}
  end

  def handle_info({:publish, topic, msg}, state) do
    IO.inspect("#{msg} from #{topic}", label: "Got message")
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, object, reason}, state) when ref == state.ref do
    IO.inspect(reason, label: "Process died")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    send(state.pid, msg)
    {:noreply, state}
  end
end
