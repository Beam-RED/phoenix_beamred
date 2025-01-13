defmodule BeamRED.Nodes.BeamModule do
  use NodeType,
    name: "beam-module",
    asset_path: "lib/beamred/nodes/beam_module"

  def setup(node) do
    code = node.fields["info"]
    # {:ok, {:module, module, _}} = BeamRED.Runtime.Evaluator.evaluate_code(code)
    # {:ok, %{module: module, code: code}}
    BeamRED.Runtime.Evaluator.evaluate_code(code)
    |> IO.inspect()

    {:ok, %{module: Test, code: code}}
  end

  def subscribe(node_id) do
    BeamRED.MQTT.Server.subscribe(["notification/node/#{node_id}"])
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
