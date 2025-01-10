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

    # get "/auth/login", NodeRedController, :login
    # post /auth/token", NodeRedController :credeitnals
    # post /auth/revoke, NodeRedController, :revoke
    get "/settings", NodeRedController, :settings
    get "/diagnostics", NodeRedController, :diagnostics
    get "/flows", NodeRedController, :flows
    get "/flows/state", NodeRedController, :flows_state
    post "/flows", NodeRedController, :new_flow
    post "/flows/state", NodeRedController, :set_runtime_state
    post "/flow", NodeRedController, :add_flow
    get "/flow/:id", NodeRedController, :get_flow
    put "/flow/:id", NodeRedController, :update_flow
    delete "/flow/:id", NodeRedController, :delete_flow
    get "/nodes", NodeRedController, :nodes
    post "/nodes", NodeRedController, :new_nodes
    get "/nodes/messages", NodeRedController, :messages
    get "/nodes/:module", NodeRedController, :get_node_module
    put "/nodes/:module", NodeRedController, :set_node_module
    delete "/nodes/:module", NodeRedController, :remove_node_module
    get "/nodes/:module/:set", NodeRedController, :get_node_set
    put "/nodes/:module/:set", NodeRedController, :set_node_set

    get "/locales/:file", NodeRedController, :locales
    get "/theme", NodeRedController, :theme
    get "/settings", NodeRedController, :settings
    get "/settings/user", NodeRedController, :user
    post "/settings/user", NodeRedController, :new_user
    get "/plugins", NodeRedController, :plugins
    get "/plugins/messages", NodeRedController, :messages
    get "/nodes", NodeRedController, :nodes
    get "/icons", NodeRedController, :icons
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
