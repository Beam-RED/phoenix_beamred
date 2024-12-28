defmodule NodeExWeb.PageController do
  use NodeExWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def locales(conn, %{"file" => file, "lng" => lng}) do
    file_path = "priv/static/assets/node-red/locales/#{lng}/#{file}.json"

    if File.exists?(file_path) do
      send_file(conn, 200, file_path)
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
          "externalModules": {},
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
              "palette": {},
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

  def new_user(conn, _params) do
    data =
      """
      {}
      """
      |> Jason.decode!()

    json(conn, data)
  end

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
              "id": "node-red/debug",
              "name": "debug",
              "types": [
                  "debug"
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
        html(conn, "")

      _ ->
        # TODO remove this
        IO.inspect(conn, label: "nodes wrong format type")
    end
  end

  def nodes_messages(conn, _params) do
    data =
      """
      {}
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
