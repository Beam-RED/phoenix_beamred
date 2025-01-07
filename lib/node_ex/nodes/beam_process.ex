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

  # @spec child_spec(any()) :: Supervisor.child_spec()
  # def child_spec(init_arg) do
  # %{
  # id: __MODULE__,
  # start: {__MODULE__, :start_link, init_arg},
  # restart: :permanent,
  # shutdown: 5000,
  # type: :worker
  # }
  # end

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
