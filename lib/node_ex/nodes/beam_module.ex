defmodule NodeEx.Nodes.BeamModule do
  use NodeType,
    name: "beam-module",
    asset_path: "lib/node_ex/nodes/beam_module"

  def setup(node) do
    code = node.fields["info"]
    # {:ok, {:module, module, _}} = NodeEx.Runtime.Evaluator.evaluate_code(code)
    # {:ok, %{module: module, code: code}}
    {:ok, %{module: Test, code: code}}
  end

  def subscribe(node_id) do
    NodeEx.MQTT.Server.subscribe(["notification/node/#{node_id}"])
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
