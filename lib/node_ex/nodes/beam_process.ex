defmodule NodeEx.Nodes.BeamProcess do
  defstruct [
    :id,
    :name,
    :type,
    :outputs,
    :run_fn
  ]

  def run(node) do
    quote do
      defmodule Hello do
        def run, do: "world"
      end
    end
    |> Macro.to_string()
    |> NodeEx.Runtime.Evaluator.evaluate_code()
  end
end
