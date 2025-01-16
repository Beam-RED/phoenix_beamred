# This is the development server for Phoenix.NodeRed
# To start the development server run:
#   $ iex dev.exs

Mix.install([
  {:phoenix_nodered, path: "."},
  {:phoenix_playground, "~> 0.1.7"}
])

otp_app = :phoenix_nodered_dev

Application.put_all_env(
  phoenix_nodered: [
    {:application, otp_app},
    {:otp_app, otp_app}
  ]
)

defmodule NodeRedDev.Router do
  use Phoenix.Router
  use Phoenix.NodeRedWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser

    nodered("/nodered", [])
  end
end

defmodule NodeRedDev.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_playground

  plug Plug.Logger
  # socket "/live", Phoenix.LiveView.Socket
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  # plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2

  # plug :set_csp
  # plug :plug_exception

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug NodeRedDev.Router
end

defmodule NodeRedDev.ErrorView do
  def render("400.html", _assigns) do
    "This is a 400"
  end

  def render("404.html", _assigns) do
    "This is a 404"
  end

  def render("406.html", _assigns) do
    "This is a 404"
  end

  def render("500.html", _assigns) do
    "This is a 500"
  end
end

PhoenixPlayground.start(
  endpoint: NodeRedDev.Endpoint,
  child_specs: [],
  open_browser: false,
  debug_errors: false
)
