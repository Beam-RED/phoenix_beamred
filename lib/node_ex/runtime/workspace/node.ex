defmodule NodeEx.Runtime.Workspace.Node do
  # Data structure representing a single node in a workspace.

  defstruct [
    :id,
    :name,
    :type,
    :outputs
  ]

  alias NodeEx.Utils
  alias NodeEx.Workspace.Node

  @type id :: Utils.id()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          type: atom(),
          outputs: list(Node.t())
        }

  @doc """
  Returns a empty node.
  """
  @spec new() :: t()
  def new() do
    %__MODULE__{
      id: nil,
      name: "",
      type: :function,
      outputs: []
    }
  end
end
