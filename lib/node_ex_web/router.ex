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

  # TODO implement missing routes from https://github.com/node-red/node-red/blob/master/packages/node_modules/%40node-red/editor-api/lib/admin/index.js

  scope "/", NodeExWeb do
    pipe_through :browser

    get "/", EditorController, :home
    get "/comms", WebsocketUpgrade, NodeExWeb.CommsSocket
  end

  scope "/locales", NodeExWeb do
    pipe_through :api

    get "/:file", LocalesController, :locales
  end

  scope "/theme", NodeExWeb do
    pipe_through :api

    get "/", EditorController, :theme
  end

  scope "/settings", NodeExWeb do
    pipe_through :api

    get "/", SettingsController, :settings
    get "/user", SettingsController, :user
    post "/user", SettingsController, :new_user
  end

  scope "/plugins", NodeExWeb do
    get "/", EditorController, :plugins
    get "/messages", EditorController, :messages
  end

  scope "/nodes", NodeExWeb do
    get "/", NodeController, :nodes
    get "/messages", NodeController, :messages
  end

  scope "/icons", NodeExWeb do
    get "/", EditorController, :icons
  end

  scope "/flows", NodeExWeb do
    get "/", EditorController, :flows
    post "/", EditorController, :new_flow
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
