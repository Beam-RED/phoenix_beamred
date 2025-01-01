defmodule NodeExWeb.NodeController do
  use NodeExWeb, :controller

  def nodes(conn, _params) do
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
          },
          {
              "id": "node-red/function",
              "name": "function",
              "types": [
                  "function"
              ],
              "enabled": true,
              "local": false,
              "user": false,
              "module": "node-red",
              "version": "4.0.8"
          },
          {
              "id": "node-red/beam-process",
              "name": "beam-process",
              "types": [
                  "beam-process"
              ],
              "enabled": true,
              "local": false,
              "user": false
          }
      ]
      """
      |> Jason.decode!()

    case conn.private[:phoenix_format] do
      "json" ->
        json(conn, data)

      "html" ->
        file_path =
          Path.join([:code.priv_dir(:node_ex), "static", "assets", "nodes", "nodes.html"])

        conn
        |> put_resp_content_type("text/html")
        |> send_file(200, file_path)

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
