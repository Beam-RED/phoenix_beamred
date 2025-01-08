defmodule NodeEx.Nodes.BeamSend do
  use GenServer

  defstruct [
    :id,
    :flow_id,
    :type,
    :outputs,
    :status,
    :fields
  ]

  alias NodeEx.Runtime

  # @spec child_spec(any()) :: Supervisor.child_spec()
  # def child_spec(node) do
  #  %{
  #    id: node.id,
  #    start: {__MODULE__, :start_link, node},
  #    restart: :permanent,
  #    shutdown: 5000,
  #    type: :worker
  #  }
  # end

  def start_link(node) do
    GenServer.start_link(__MODULE__, node, name: via_tuple(node.id))
  end

  def init(node) do
    :ok = NodeExWeb.Channel.Server.subscribe(["notification/node/#{node.id}"])
    IO.inspect(node)

    case Code.string_to_quoted(node.fields["msg"]) do
      {:ok, _} ->
        Runtime.set_node_status(node.flow_id, node.id, {"Success", :grey, :ring})

      {:error, reason} ->
        IO.inspect(reason)
        Runtime.set_node_status(node.flow_id, node.id, {"TEST", :grey, :ring})
    end

    {:ok, %{id: node.id, outputs: hd(node.outputs), message: node.fields["msg"]}}
  end

  def handle_info({:publish, "notification/node/" <> node_id, "send"}, state) do
    IO.inspect(state, label: "Send")

    Enum.each(state.outputs, fn output ->
      {:ok, pid} = Runtime.get_node_pid(output)
      send(pid, state.message)
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

  defp get_pid(name) do
    Module.concat([name])
    |> Process.whereis()
  end

  defp via_tuple(id), do: {:via, Registry, {NodeEx.Runtime.Registry, id}}
end
