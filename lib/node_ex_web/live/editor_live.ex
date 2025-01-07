defmodule NodeExWeb.EditorLive do
  use NodeExWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Hello World</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
