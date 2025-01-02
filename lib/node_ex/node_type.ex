defmodule NodeEx.NodeType do
  @moduledoc ~S'''

  '''

  defstruct [:js, :template, :help_text]

  @opaque t :: %__MODULE__{}

  @doc """
  Main node definition.
  """
  @callback js(node_name :: String.t()) :: String.t()

  @doc """
  Template of the node.
  """
  @callback template(node_name :: String.t()) :: String.t()

  @doc """
  The help text of the node.
  """
  @callback help_text(node_name :: String.t()) :: String.t()

  defmacro __using__(_opts) do
    node_name =
      __CALLER__.module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()
      |> String.replace("_", "-")

    quote location: :keep do
      @behaviour NodeEx.NodeType

      def to_nodered() do
        """
        <script type="text/javascript">
        #{js(unquote(node_name))}
        </script>

        <script type="text/html" data-template-name="#{unquote(node_name)}">
        #{template(unquote(node_name))}
        </script>

        <script type="text/html" data-help-name="#{unquote(node_name)}">
        #{help_text(unquote(node_name))}
        </script>
        """
      end
    end
  end
end

defimpl Enumerable, for: NodeEx.NodeType do
  def reduce(node, acc, fun), do: nil
  def member?(_node, _value), do: {:error, __MODULE__}
  def count(_node), do: {:error, __MODULE__}
  def slice(_node), do: {:error, __MODULE__}
end
