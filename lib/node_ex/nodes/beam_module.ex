defmodule NodeEx.Nodes.BeamModule do
  use NodeType, asset_path: "lib/node_ex/nodes/beam_module.html"

  def setup(node) do
    code = node.fields["info"]
    #{:ok, {:module, module, _}} = NodeEx.Runtime.Evaluator.evaluate_code(code)
    #{:ok, %{module: module, code: code}}
    {:ok, %{module: Test, code: code}}
  end

  def handle_info({:apply, function, args}, %{module: module} = state) do
    apply(module, function, args)
    {:norely, state}
  end

  def handle_info({:publish, topic, msg}, state) do
    IO.inspect("#{msg} from #{topic}", label: "Got message")
    {:noreply, state}
  end
end
