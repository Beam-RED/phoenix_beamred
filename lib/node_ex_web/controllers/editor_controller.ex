defmodule NodeExWeb.EditorController do
  use NodeExWeb, :controller

  alias NodeExWeb.Channel.Server
  alias NodeEx.Runtime

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def plugins(conn, _params) do
    data =
      """
      []
      """
      |> Jason.decode!()

    case conn.private[:phoenix_format] do
      "json" ->
        json(conn, data)

      "html" ->
        html(conn, "")

      _ ->
        # TODO remove this
        IO.inspect(conn, label: "plugins wrong format type")
    end
  end

  def messages(conn, _params) do
    data =
      """
      {}
      """
      |> Jason.decode!()

    json(conn, data)
  end

  def new_flow(conn, %{"flows" => flows} = params) do
    deployment_type =
      case get_req_header(conn, "node-red-deployment-type") do
        ["full"] -> :full
        ["flows"] -> :flows
        ["nodes"] -> :nodes
        ["reload"] -> :reload
        _ -> :full
      end

    IO.inspect(deployment_type, label: "Deployment Type")
    IO.inspect(params)

    rev = params["rev"]

    if !rev || rev == NodeEx.Storage.get_rev() do
      new_rev = NodeEx.Storage.save_flows(flows)

      NodeEx.Runtime.deploy_flows(flows, deployment_type)
      # TODO send this from runtime
      Server.publish("notification/runtime-state", %{state: "stop", deploy: true})
      Server.publish("notification/runtime-state", %{state: "start", deploy: true})
      Server.publish("notification/runtime-deploy", %{revision: ""})

      json(conn, %{rev: new_rev})
    else
      conn
      |> put_status(409)
      |> json(%{code: "version_mismatch", message: "Error"})
    end
  end

  def icons(conn, _params) do
    data =
      """
      {}
      """
      |> Jason.decode!()

    json(conn, data)
  end

  def flows(conn, _params) do
    {rev, flows} = NodeEx.Storage.get_flows()

    json(conn, %{flows: flows, rev: rev})
  end
end
