defmodule NodeEx.Nodes.BeamProcess do
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

  def start_link(node) do
    GenServer.start_link(__MODULE__, node, name: via_tuple(node.id))
  end

  def init(node) do
    :ok = NodeExWeb.Channel.Server.subscribe(["notification/node/#{node.id}"])

    pid = get_pid(node.fields["name"])
    if is_nil(pid), do: Runtime.set_node_status(node.flow_id, node.id, {"Error", :red, :dot})

    ref = Process.monitor(pid)

    {:ok, %{pid: pid, ref: ref}}
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
