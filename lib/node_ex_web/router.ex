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

  scope "/", NodeExWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/comms", WebsocketUpgrade, NodeExWeb.CommsSocket
  end

  scope "/locales", NodeExWeb do
    pipe_through :api

    get ":file", PageController, :locales
  end

  scope "/theme", NodeExWeb do
    pipe_through :api

    get "/", PageController, :theme
  end

  scope "/settings", NodeExWeb do
    pipe_through :api

    get "/", PageController, :settings
    get "/user", PageController, :user
    post "/user", PageController, :new_user
  end

  scope "/plugins", NodeExWeb do
    get "/", PageController, :plugins
    get "/messages", PageController, :messages
  end

  scope "/nodes", NodeExWeb do
    get "/", PageController, :nodes
    get "/messages", PageController, :nodes_messages
  end

  scope "/icons", NodeExWeb do
    get "/", PageController, :icons
  end

  scope "/flows", NodeExWeb do
    get "/", PageController, :flows
  end

  # Other scopes may use custom stacks.
  # scope "/api", NodeExWeb do
  #   pipe_through :api
  # end

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
