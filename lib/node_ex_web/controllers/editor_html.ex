defmodule NodeExWeb.EditorHTML do
  @moduledoc """
  """
  use NodeExWeb, :html

  def render(_template, assigns) do
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
        <link rel="icon" type="image/png" href={~p"/assets/node-red/public/favicon.ico"} />
        <link
          rel="mask-icon"
          href={~p"/assets/node-red/public/red/node-red-icon-black.svg"}
          color="#8f0000"
        />
        <link
          rel="stylesheet"
          href={~p"/assets/node-red/public/vendor/jquery/css/base/jquery-ui.min.css"}
        />
        <link
          rel="stylesheet"
          href={~p"/assets/node-red/public/vendor/font-awesome/css/font-awesome.min.css"}
        />
        <link rel="stylesheet" href={~p"/assets/node-red/public/red/style.min.css"} />
        <link rel="stylesheet" href={~p"/assets/node-red/public/vendor/monaco/style.css"} />
      </head>
      <body spellcheck="false">
        <div id="red-ui-editor"></div>
        <script src={~p"/assets/node-red/public/vendor/vendor.js"}>
        </script>
        <script src={~p"/assets/node-red/public/vendor/monaco/dist/editor.js"}>
        </script>
        <script src={~p"/assets/node-red/public/red/red.js"}>
        </script>
        <script src={~p"/assets/app.js"}>
        </script>
        <script>
          //RED.init();
          //RED.sessionMessages = {{{sessionMessages}}};
        </script>
      </body>
    </html>
    """
  end
end
