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
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # TODO implement missing routes from https://github.com/node-red/node-red/blob/master/packages/node_modules/%40node-red/editor-api/lib/admin/index.js

  scope "/", NodeExWeb do
    pipe_through :nodered

    get "/", EditorController, :home
    get "/comms", WebsocketUpgrade, NodeExWeb.CommsSocket
    get "/locales/:file", LocalesController, :locales
    get "/theme", SettingsController, :theme
    get "/settings", SettingsController, :settings
    get "/settings/user", SettingsController, :user
    post "/settings/user", SettingsController, :new_user
    get "/plugins", EditorController, :plugins
    get "/plugins/messages", EditorController, :messages
    get "/nodes", NodeController, :nodes
    get "/nodes/messages", NodeController, :messages
    get "/icons", EditorController, :icons
    get "/flows", EditorController, :flows
    post "/flows", EditorController, :new_flow
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
