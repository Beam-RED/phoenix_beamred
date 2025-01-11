defmodule NodeEx.NodesManager do
  use GenServer

  import NodeEx.Utils, only: [has_function?: 3]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  """
  @spec register(module()) :: :ok
  def register(module) do
    IO.inspect(module.__node_definition__)

    if not has_function?(module, :__node_definition__, 0) do
      raise ArgumentError, "module #{inspect(module)} does not define a NodeRed node"
    end

    GenServer.cast(__MODULE__, {:register, module, module.__node_definition__()})
  end

  @doc """
  """
  @spec get_nodes() :: GenServer.on_start()
  def get_nodes() do
    GenServer.call(__MODULE__, :get_nodes)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, module, definition}, state) do
    {:noreply, Map.put(state, module, definition)}
  end

  @impl true
  def handle_call(:get_nodes, _from, state) do
    nodes =
      state
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.join("\n\n")

    {:reply, nodes, state}
  end
end
