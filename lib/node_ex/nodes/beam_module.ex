defmodule NodeEx.Nodes.BeamModule do
  use NodeEx.NodeType

  def setup(node) do
    code = node.fields["info"]
    NodeEx.Runtime.Evaluator.evaluate_code(code)
    {:ok, %{code: code}}
  end

  def handle_info({:publish, topic, msg}, state) do
    IO.inspect("#{msg} from #{topic}", label: "Got message")
    {:noreply, state}
  end
end
