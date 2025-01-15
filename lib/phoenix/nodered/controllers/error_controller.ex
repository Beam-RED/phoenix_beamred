defmodule Phoenix.NodeRedWeb.ErrorController do
  use Phoenix.NodeRedWeb, :controller

  def notfound(conn, _params) do
    conn
    |> put_status(:not_found)
    |> text("404 - Page Not Found")
  end
end
