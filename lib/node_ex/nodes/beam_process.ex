defmodule NodeEx.Nodes.BeamProcess do
  use GenServer

  defstruct [
    :id,
    :name,
    :type,
    :outputs
  ]

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

    pid = get_pid(node.name)
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
end
