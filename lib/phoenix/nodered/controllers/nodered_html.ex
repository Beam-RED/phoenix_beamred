defmodule Phoenix.NodeRedWeb.NodeRedHTML do
  @moduledoc """
  """
  use Phoenix.NodeRedWeb, :html

  def render(_template, assigns) do
    path = assigns.conn.request_path

    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta
          name="viewport"
          content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"
        />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="mobile-web-app-capable" content="yes" />
        <title>Editor</title>
        <link rel="icon" type="image/png" href="/favicon.ico" />
        <link rel="mask-icon" href={"#{path}red/node-red-icon-black.svg"} color="#8f0000" />
        <link rel="stylesheet" href={"#{path}vendor/jquery/css/base/jquery-ui.min.css"} />
        <link rel="stylesheet" href={"#{path}vendor/font-awesome/css/font-awesome.min.css"} />
        <link rel="stylesheet" href={"#{path}red/style.min.css"} />
        <link rel="stylesheet" href={"#{path}vendor/monaco/style.css"} />
      </head>
      <body spellcheck="false">
        <div id="red-ui-editor"></div>
        <script src={"#{path}vendor/vendor.js"}>
        </script>
        <script src={"#{path}vendor/monaco/dist/editor.js"}>
        </script>
        <script src={"#{path}red/red.js"}>
        </script>
        <script src={"#{path}red/main.js"}>
        </script>
      </body>
    </html>
    """
  end
end
