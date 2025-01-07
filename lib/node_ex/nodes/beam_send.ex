defmodule NodeEx.Nodes.BeamSend do
  use GenServer

  defstruct [
    :id,
    :type,
    :outputs,
    :fields
  ]

  alias NodeEx.Runtime

  # @spec child_spec(any()) :: Supervisor.child_spec()
  # def child_spec(init_arg) do
  # %{
  # id: __MODULE__,
  # start: {__MODULE__, :start_link, init_arg},
  # restart: :permanent,
  # shutdown: 5000,
  # type: :worker
  # }
  # end

  def start_link(node) do
    GenServer.start_link(__MODULE__, node)
  end

  def init(node) do
    :ok = NodeExWeb.Channel.Server.subscribe(["notification/node/#{node.id}"])
    IO.inspect(node)

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
end
