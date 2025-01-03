defmodule NodeEx.Runtime.Expr do
  defstruct [:code]

  def new(code) do
    %__MODULE__{code: code}
  end
end
