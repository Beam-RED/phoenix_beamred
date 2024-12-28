defmodule NodeExWeb.NodeController do
  use NodeExWeb, :controller

  @default_nodes Path.join(__DIR__, "../nodes")
                 |> File.ls!()
                 |> Enum.map(fn node ->
                   File.read!(Path.join([__DIR__, "../nodes", node]))
                 end)
                 |> Enum.join("\n\n")

  def nodes(conn, _params) do
    conn = accepts(conn, ["json", "html"])

    data =
      """
      [
          {
              "id": "node-red/junction",
              "name": "junction",
              "types": [
                  "junction"
              ],
              "enabled": true,
              "local": false,
              "user": false,
              "module": "node-red",
              "version": "4.0.8"
          },
          {
              "id": "node-red/inject",
              "name": "inject",
              "types": [
                  "inject"
              ],
              "enabled": true,
              "local": false,
              "user": false,
              "module": "node-red",
              "version": "4.0.8"
          },
          {
              "id": "node-red/complete",
              "name": "complete",
              "types": [
                  "complete"
              ],
              "enabled": true,
              "local": false,
              "user": false,
              "module": "node-red",
              "version": "4.0.8"
          }
      ]
      """
      |> Jason.decode!()

    case conn.private[:phoenix_format] do
      "json" ->
        json(conn, data)

      "html" ->
        html(conn, @default_nodes)

      _ ->
        # TODO remove this
        IO.inspect(conn, label: "nodes wrong format type")
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
end
