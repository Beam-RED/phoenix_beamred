defmodule NodeEx.Nodes.BeamModule do
  use GenServer

  defstruct [
    :id,
    :type,
    :outputs,
    :fields
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
    IO.inspect(node)
    :ok = NodeExWeb.Channel.Server.subscribe(["notification/node/#{node.id}"])

    code = node.fields["info"]

    NodeEx.Runtime.Evaluator.evaluate_code(code)
    |> IO.inspect(label: "Code evaluated")

    {:ok, %{code: code}}
  end

  def handle_info({:publish, topic, msg}, state) do
    IO.inspect("#{msg} from #{topic}", label: "Got message")
    {:noreply, state}
  end
end
