defmodule Phoenix.NodeRed.Router do
  defmacro nodered(path, opts \\ []) do
    opts =
      if Macro.quoted_literal?(opts) do
        Macro.prewalk(opts, &expand_alias(&1, __CALLER__))
      else
        opts
      end

    quote bind_quoted: binding() do
      pipeline :static do
        plug(Plug.Static,
          at: "/#{path}",
          from: {:phoenix_nodered, "priv/static/assets/node-red/public"},
          gzip: false
        )

        plug(Plug.Static,
          at: "/#{path}/icons/node-red",
          from: {:phoenix_nodered, "priv/static/assets/nodes/icons"},
          gzip: false
        )
      end

      scope path, alias: false, as: false do
        # TODO: only import function which are needed
        import Phoenix.Router

        pipe_through(:static)
        |> dbg()

        get("/", Phoenix.NodeRedWeb.NodeRedController, :home)
        get("/comms", Phoenix.WebsocketUpgrade, NodeRedWeb.CommsSocket)

        # get "/auth/login", Phoenix.NodeRedController, :login
        # post /auth/token", Phoenix.NodeRedController :credeitnals
        # post /auth/revoke, Phoenix.NodeRedController, :revoke
        get("/settings", Phoenix.NodeRedWeb.NodeRedController, :settings)
        get("/diagnostics", Phoenix.NodeRedWeb.NodeRedController, :diagnostics)
        get("/flows", Phoenix.NodeRedWeb.NodeRedController, :flows)
        get("/flows/state", Phoenix.NodeRedWeb.NodeRedController, :flows_state)
        post("/flows", Phoenix.NodeRedWeb.NodeRedController, :new_flow)
        post("/flows/state", Phoenix.NodeRedWeb.NodeRedController, :set_runtime_state)
        post("/flow", Phoenix.NodeRedWeb.NodeRedController, :add_flow)
        get("/flow/:id", Phoenix.NodeRedWeb.NodeRedController, :get_flow)
        put("/flow/:id", Phoenix.NodeRedWeb.NodeRedController, :update_flow)
        delete("/flow/:id", Phoenix.NodeRedWeb.NodeRedController, :delete_flow)
        get("/nodes", Phoenix.NodeRedWeb.NodeRedController, :nodes)
        post("/nodes", Phoenix.NodeRedWeb.NodeRedController, :new_nodes)
        get("/nodes/messages", Phoenix.NodeRedWeb.NodeRedController, :messages)
        get("/nodes/:module", Phoenix.NodeRedWeb.NodeRedController, :get_node_module)
        put("/nodes/:module", Phoenix.NodeRedWeb.NodeRedController, :set_node_module)
        delete("/nodes/:module", Phoenix.NodeRedWeb.NodeRedController, :remove_node_module)
        get("/nodes/:module/:set", Phoenix.NodeRedWeb.NodeRedController, :get_node_set)
        put("/nodes/:module/:set", Phoenix.NodeRedWeb.NodeRedController, :set_node_set)

        get("/locales/:file", Phoenix.NodeRedWeb.NodeRedController, :locales)
        get("/theme", Phoenix.NodeRedWeb.NodeRedController, :theme)
        get("/settings", Phoenix.NodeRedWeb.NodeRedController, :settings)
        get("/settings/user", Phoenix.NodeRedWeb.NodeRedController, :user)
        post("/settings/user", Phoenix.NodeRedWeb.NodeRedController, :new_user)
        get("/plugins", Phoenix.NodeRedWeb.NodeRedController, :plugins)
        get("/plugins/messages", Phoenix.NodeRedWeb.NodeRedController, :messages)
        get("/nodes", Phoenix.NodeRedWeb.NodeRedController, :nodes)
        get("/icons", Phoenix.NodeRedWeb.NodeRedController, :icons)

        get("/*path", ErrorController, :notfound)
      end
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env) do
    Macro.expand(alias, %{env | function: {:nodered, 2}})
  end

  defp expand_alias(other, _env), do: other
end
