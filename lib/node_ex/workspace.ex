defmodule NodeEx.Workspace do
  # Data structure representing a NodeRed workspace.
  #
  # A workspace is the datastructure NodeRed outputs as a json file.

  defstruct [
    :flows,
    :revision
  ]

  alias NodeEx.Workspace.Flow

  @type t :: %__MODULE__{
          flows: list(Flow.t()),
          revision: non_neg_integer() | nil
        }

  @doc """
  Returns a blank workspace.
  """
  @spec new() :: t()
  def new() do
    %__MODULE__{
      flows: [],
      revision: nil
    }
  end
end
