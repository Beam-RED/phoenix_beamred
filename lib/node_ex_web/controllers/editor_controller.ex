defmodule NodeExWeb.NodeRedController do
  use NodeExWeb, :controller

  alias NodeEx.MQTT.Server

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

    rev = params["rev"]

    if !rev || rev == NodeEx.Runtime.Storage.get_rev() do
      new_rev = NodeEx.Runtime.Storage.save_flows(flows)

      NodeEx.Runtime.deploy_flows(flows, deployment_type)

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
    {rev, flows} = NodeEx.Runtime.Storage.get_flows()

    json(conn, %{flows: flows, rev: rev})
  end

  def nodes(conn, _params) do
    data =
      """
      [
          {
              "id": "node-red/beam",
              "name": "beam",
              "types": [
                  "beam-process",
                  "beam-send",
                  "beam-module",
                  "comment"
              ],
              "enabled": true,
              "local": false,
              "user": false,
              "module": "beam",
              "version": "4.0.8"
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

  def locales(conn, %{"file" => file, "lng" => lng}) do
    file_path = get_file_path(file, lng)

    if File.exists?(file_path) do
      conn
      |> put_resp_content_type("application/json")
      |> send_file(200, file_path)
    else
      json(conn, "{}")
    end
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

  def settings(conn, _params) do
    data =
      """
      {
          "httpNodeRoot": "/",
          "version": "4.0.8",
          "context": {
              "default": "memory",
              "stores": [
                  "memory"
              ]
          },
          "codeEditor": {
              "lib": "monaco",
              "options": {}
          },
          "markdownEditor": {
              "mermaid": {
                  "enabled": true
              }
          },
          "libraries": [
              {
                  "id": "local",
                  "label": "editor:library.types.local",
                  "user": false,
                  "icon": "font-awesome/fa-hdd-o"
              },
              {
                  "id": "examples",
                  "label": "editor:library.types.examples",
                  "user": false,
                  "icon": "font-awesome/fa-life-ring",
                  "types": [
                      "flows"
                  ],
                  "readOnly": true
              }
          ],
          "flowFilePretty": true,
          "externalModules": {
            "palette": {
              "allowInstall": true
            }
          },
          "flowEncryptionType": "system",
          "diagnostics": {
              "enabled": true,
              "ui": true
          },
          "runtimeState": {
              "enabled": false,
              "ui": false
          },
          "functionExternalModules": true,
          "functionTimeout": 0,
          "tlsConfigDisableLocalFiles": false,
          "editorTheme": {
              "palette": {
                "catalogues": []
              },
              "projects": {
                  "enabled": false,
                  "workflow": {
                      "mode": "manual"
                  }
              },
              "multiplayer": {
                  "enabled": false
              },
              "languages": [
                  "de",
                  "en-US",
                  "es-ES",
                  "fr",
                  "ja",
                  "ko",
                  "pt-BR",
                  "ru",
                  "zh-CN",
                  "zh-TW"
              ]
          }
      }
      """
      |> Jason.decode!()

    json(conn, data)
  end

  def user(conn, _params) do
    data =
      """
      {
          "editor": {
              "view": {
                  "view-store-zoom": false,
                  "view-store-position": false,
                  "view-show-grid": true,
                  "view-snap-grid": true,
                  "view-grid-size": "20",
                  "view-node-status": true,
                  "view-node-show-label": true,
                  "view-show-tips": true,
                  "view-show-welcome-tours": true
              },
              "tours": {
                  "welcome": "4.0.8"
              },
              "dialog": {
                  "export": {
                      "pretty": true,
                      "json-view": true
                  }
              }
          },
          "menu-menu-item-sidebar": true,
          "menu-deploymenu-item-flow": true,
          "menu-deploymenu-item-full": false,
          "menu-deploymenu-item-node": false
      }
      """
      |> Jason.decode!()

    json(conn, data)
  end

  def new_user(conn, _params) do
    data =
      """
      {}
      """
      |> Jason.decode!()

    json(conn, data)
  end

  defp get_file_path("node-red", lng) do
    "priv/static/assets/nodes/locales/#{lng}/messages.json"
  end

  defp get_file_path(file, lng) do
    "priv/static/assets/node-red/locales/#{lng}/#{file}.json"
  end
end
