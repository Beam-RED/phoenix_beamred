defmodule NodeEx.Nodes.BeamProcess do
  use GenServer

  defstruct [
    :module,
    :id,
    :name,
    :type,
    :outputs
  ]

  alias NodeEx.Runtime.Evaluator

  def start_link(node) do
    GenServer.start_link(__MODULE__, node)
  end

  def init(node) do
    quote do
      defmodule Hello do
        def run, do: "world"
      end
    end
    |> Macro.to_string()
    |> Evaluator.evaluate_code()

    {:ok, node}
  end
end
