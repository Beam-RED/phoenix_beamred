defmodule NodeEx.Runtime.Workspace.Node do
  # Data structure representing a single node in a workspace.

  defstruct [
    :id,
    :name,
    :type,
    :outputs,
    :run_fn
  ]

  alias NodeEx.Utils

  @type id :: Utils.id()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          type: String.t(),
          outputs: list(id()),
          run_fn: fun(list(term()))
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
        name: node["name"],
        type: node["type"],
        outputs: node["wires"],
        run_fn: &node_module.run/1
      })
    else
      {:not_loaded, node_module}
    end
  end

  defp get_module_name(type) do
    type
    |> String.replace("-", "_")
    |> Macro.camelize()
    |> String.to_atom()
  end
end
