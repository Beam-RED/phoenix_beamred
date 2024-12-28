defmodule NodeExWeb.LocalesController do
  use NodeExWeb, :controller

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

  defp get_file_path("node-red", lng) do
    "priv/static/assets/nodes/locales/#{lng}/messages.json"
  end

  defp get_file_path(file, lng) do
    "priv/static/assets/node-red/locales/#{lng}/#{file}.json"
  end
end
