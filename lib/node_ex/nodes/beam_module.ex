defmodule NodeEx.Nodes.BeamModule do
  use GenServer

  defstruct [
    :id,
    :flow_id,
    :type,
    :outputs,
    :status,
    :fields
  ]

  def start_link(node) do
    GenServer.start_link(__MODULE__, node, name: via_tuple(node.id))
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

  defp via_tuple(id), do: {:via, Registry, {NodeEx.Runtime.Registry, id}}
end
