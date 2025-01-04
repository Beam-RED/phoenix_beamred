defmodule NodeEx.Runtime.Workspace.Node do
  # Data structure representing a single node in a workspace.

  defstruct [
    :id,
    :name,
    :type
  ]

  alias NodeEx.Utils

  @type id :: Utils.id()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          type: atom()
        }

  @doc """
  Returns a empty node.
  """
  @spec new(map()) :: t()
  def new(node) do
    %__MODULE__{
      id: nil,
      name: "",
      type: :function
    }
    |> struct(node)
  end
end
