defmodule NodeEx.Nodes.BeamProcess do
  use NodeEx.NodeType

  def js(node_name) do
    """
    RED.nodes.registerType("#{node_name}", {
        category: "beam",
        color: "#a6bbcf",
        defaults: {
            name: { value: "" },
        },
        inputs: 1,
        outputs: 0,
        icon: "file.svg",
        label: function () {
            return this.name || "#{node_name}";
        },
    });
    """
  end

  def template(_node_name) do
    """
    <div class="form-row">
        <label for="node-input-name"><i class="fa fa-tag"></i> Name</label>
        <input type="text" id="node-input-name" placeholder="Name" />
    </div>
    """
  end

  def help_text(_node_name) do
    """
    <p>
        A simple node that converts the message payloads into all lower-case
        characters
    </p>
    """
  end
end
