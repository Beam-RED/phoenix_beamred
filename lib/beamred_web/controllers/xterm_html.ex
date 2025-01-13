defmodule BeamREDWeb.XtermHTML do
  @moduledoc """
  """
  use BeamREDWeb, :html

  def render(_template, assigns) do
    ~H"""
    <!doctype html>
    <html>
      <head>
        <link rel="stylesheet" href={~p"/assets/xterm.css"} />
      </head>
      <body>
        <div id="terminal"></div>
        <script src={~p"/assets/xterm.js"}>
        </script>
      </body>
    </html>
    """
  end
end
