defmodule NodeExWeb.CommsSocket do
  use NodeExWeb, :verified_routes
  @behaviour WebSock

  @impl true
  def init(_params) do
    {:ok, %{}}
  end

  @impl true
  def handle_in(msg, state) do
    IO.inspect(msg, label: "handle_in")
    {:ok, state}
  end

  @impl true
  def handle_info(msg, state) do
    IO.inspect(msg, label: "handle_info")
    {:ok, state}
  end
end
