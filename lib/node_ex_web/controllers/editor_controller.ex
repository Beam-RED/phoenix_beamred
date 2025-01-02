defmodule NodeExWeb.EditorController do
  use NodeExWeb, :controller

  alias NodeExWeb.Channel.Server

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

  def new_flow(conn, params) do
    deployment_type =
      case get_req_header(conn, "node-red-deployment-type") do
        ["flows"] -> :flows
        ["full"] -> :full
        ["nodes"] -> :nodes
        ["reload"] -> :reload
        # TODO print to logger, do not raise
        type -> raise "Unkown deployment type #{inspect(type)}"
      end

    IO.inspect(deployment_type, label: "Deployment Type")
    IO.inspect(params)

    data =
      """
      {"rev":"null"}
      """
      |> Jason.decode!()

    Server.publish("notification/runtime-state", %{state: "stop", deploy: true})
    Server.publish("notification/runtime-state", %{state: "start", deploy: true})
    Server.publish("notification/runtime-deploy", %{revision: ""})

    json(conn, data)
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
    data =
      """
      {
      "flows": []
      }
      """
      |> Jason.decode!()

    json(conn, data)
  end
end
