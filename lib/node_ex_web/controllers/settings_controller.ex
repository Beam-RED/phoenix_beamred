defmodule NodeExWeb.SettingsController do
  use NodeExWeb, :controller

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

  def new_user(conn, _params) do
    data =
      """
      {}
      """
      |> Jason.decode!()

    json(conn, data)
  end
end
