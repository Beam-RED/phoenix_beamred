defmodule NodeExWeb.Socket do
  use Phoenix.Socket

  channel "iex:session", NodeExWeb.IExChannel

  @impl true
  def connect(_params, socket, _info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
