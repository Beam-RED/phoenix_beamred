defmodule BeamREDWeb.XtermController do
  use BeamREDWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
