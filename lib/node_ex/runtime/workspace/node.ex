defmodule NodeEx.Runtime.Workspace.Node do
  # Data structure representing a single node in a workspace.

  defstruct [
    :id,
    :flow_id,
    :type,
    :outputs,
    :status,
    :fields
  ]

  alias NodeEx.Utils
  alias NodeEx.Workspace.Flow

  @type id :: Utils.id()

  @type status_color :: :red | :green | :yellow | :blue | :grey
  @type status_shape :: :ring | :dot

  @type status :: {String.t(), status_shape(), status_color()}

  @type t :: %__MODULE__{
          id: id(),
          flow_id: Flow.id(),
          type: String.t(),
          outputs: list(id()),
          status: status() | nil,
          fields: map()
        }

  @doc """
  Returns a empty node.
  """
  @spec new(String.t(), map()) :: struct() | {:not_loaded, atom()}
  def new(type, node) do
    node_module = Module.concat([NodeEx.Nodes, get_module_name(type)])

    if Code.ensure_loaded?(node_module) do
      struct(node_module, %{
        id: node["id"],
        flow_id: node["z"],
        type: node["type"],
        outputs: node["wires"],
        status: nil,
        fields: node
      })
    else
      {:not_loaded, node_module}
    end
  end

  @doc """
  Sets the status of the node.
  """
  @spec set_status(t(), status()) :: t()
  def set_status(node, status) do
    %{node | status: status}
  end

  defp get_module_name(type) do
    type
    |> String.replace("-", "_")
    |> Macro.camelize()
    |> String.to_atom()
  end
end
