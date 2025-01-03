defmodule NodeExWeb.XtermController do
  use NodeExWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
