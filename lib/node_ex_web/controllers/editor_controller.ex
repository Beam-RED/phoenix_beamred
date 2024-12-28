defmodule NodeExWeb.EditorController do
  use NodeExWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def theme(conn, _params) do
    data =
      """
      {
          "page": {
              "title": "Node-RED",
              "favicon": "favicon.ico",
              "tabicon": {
                  "icon": "red/images/node-red-icon-black.svg",
                  "colour": "#8f0000"
              }
          },
          "header": {
              "title": "Node-RED",
              "image": "red/images/node-red.svg"
          },
          "asset": {
              "red": "red/red.min.js",
              "main": "red/main.min.js",
              "vendorMonaco": "vendor/monaco/monaco-bootstrap.js"
          },
          "themes": []
      }
      """
      |> Jason.decode!()

    json(conn, data)
  end

  def plugins(conn, _params) do
    conn = accepts(conn, ["json", "html"])

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
      |> IO.inspect(label: "Deployment type")

    data =
      """
      {"rev":"null"}
      """
      |> Jason.decode!()

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
