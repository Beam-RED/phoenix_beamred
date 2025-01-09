defmodule NodeExWeb.Router do
  use NodeExWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :nodered do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_secure_browser_headers
  end

  # TODO implement missing routes from https://github.com/node-red/node-red/blob/master/packages/node_modules/%40node-red/editor-api/lib/admin/index.js
  scope "/", NodeExWeb do
    pipe_through :nodered

    get "/", NodeRedController, :home
    get "/comms", WebsocketUpgrade, NodeExWeb.CommsSocket
    get "/locales/:file", NodeRedController, :locales
    get "/theme", NodeRedController, :theme
    get "/settings", NodeRedController, :settings
    get "/settings/user", NodeRedController, :user
    post "/settings/user", NodeRedController, :new_user
    get "/plugins", NodeRedController, :plugins
    get "/plugins/messages", NodeRedController, :messages
    get "/nodes", NodeRedController, :nodes
    get "/nodes/messages", NodeRedController, :messages
    get "/icons", NodeRedController, :icons
    get "/flows", NodeRedController, :flows
    post "/flows", NodeRedController, :new_flow
  end

  scope "/xterm", NodeExWeb do
    pipe_through :browser

    get "/", XtermController, :home
  end

  scope "/editor", NodeExWeb do
    pipe_through :browser

    live "/", EditorLive
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:node_ex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NodeExWeb.Telemetry
    end
  end
end
