defmodule NodeExWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :node_ex

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_node_ex_key",
    signing_salt: "xL1EBw89",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  socket "/socket", NodeExWeb.Socket,
    websocket: true,
    longpoll: true

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :node_ex,
    gzip: false,
    only: NodeExWeb.static_paths()

  plug Plug.Static,
    at: "/red",
    from: {:node_ex, "priv/static/assets/node-red/public/red"},
    gzip: false

  plug Plug.Static,
    at: "/types",
    from: {:node_ex, "priv/static/assets/node-red/public/types"},
    gzip: false

  plug Plug.Static,
    at: "/vendor",
    from: {:node_ex, "priv/static/assets/node-red/public/vendor"},
    gzip: false

  plug Plug.Static,
    at: "/icons/node-red",
    from: {:node_ex, "priv/static/assets/nodes/icons"},
    gzip: false

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug NodeExWeb.Router
end
