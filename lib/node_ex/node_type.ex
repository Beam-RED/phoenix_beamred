defmodule NodeEx.NodeType do
  @moduledoc ~S'''

  '''

  defstruct [:node]

  alias NodeEx.Runtime.Workspace

  @opaque t :: %__MODULE__{
            node: Workspace.Node.t()
          }

  @doc """
  """
  @callback setup(node :: Workspace.Node.t()) :: {:ok, map()}

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour NodeEx.NodeType

      use GenServer

      def start_link(node) do
        GenServer.start_link(__MODULE__, node, name: via_tuple(node.id))
      end

      def init(node) do
        :ok = NodeExWeb.Channel.Server.subscribe(["notification/node/#{node.id}"])
        {:ok, state} = setup(node)
        {:ok, state}
      end

      defp via_tuple(id), do: {:via, Registry, {NodeEx.Runtime.Registry, id}}
    end
  end
end
