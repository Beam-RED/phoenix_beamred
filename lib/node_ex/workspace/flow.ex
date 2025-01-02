defmodule NodeEx.Workspace.Flow do
  # Data structure representing a single flow in a workspace.

  defstruct [:id, :name, :nodes]

  alias NodeEx.Utils
  alias NodeEx.Workspace.Node

  @type id :: Utils.id()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          nodes: list(Node.t())
        }

  @doc """
  Returns a blank flow.
  """
  @spec new() :: t()
  def new() do
    %__MODULE__{
      id: nil,
      name: nil,
      nodes: []
    }
  end
end
