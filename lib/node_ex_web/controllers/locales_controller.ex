defmodule NodeExWeb.LocalesController do
  use NodeExWeb, :controller

  def locales(conn, %{"file" => file, "lng" => lng}) do
    file_path = "priv/static/assets/node-red/locales/#{lng}/#{file}.json"

    if File.exists?(file_path) do
      send_file(conn, 200, file_path)
    else
      json(conn, "{}")
    end
  end
end
