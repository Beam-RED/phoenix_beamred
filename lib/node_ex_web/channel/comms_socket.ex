defmodule NodeExWeb.Channel.CommsSocket do
  use NodeExWeb, :verified_routes
  @behaviour WebSock

  @hb_interval 15000

  alias NodeExWeb.Channel.Server

  @impl true
  def init(_params) do
    time_stamp = :os.system_time(:millisecond)

    Process.send_after(self(), {:hb, time_stamp}, @hb_interval)
    {:ok, %{}}
  end

  @impl true
  def handle_in({msg, _}, state) do
    case Jason.decode(msg) do
      {:ok, json} -> handle_msg(json)
      error -> IO.inspect(error)
    end

    {:ok, state}
  end

  defp handle_msg(%{"subscribe" => topic}) do
    Server.subscribe([topic])
  end

  defp handle_msg(%{"topic" => topic, "data" => data}) do
    node = String.split(topic, "/") |> List.last()
    send(self(), {:set_status, node, "TEST"})
  end

  defp handle_msg(msg) do
    IO.inspect(msg, label: "Last handle msg")
  end

  @impl true
  def handle_info({:publish, topic, data}, state) do
    data = [%{topic: topic, data: data}] |> Jason.encode!()
    {:push, {:text, data}, state}
  end

  def handle_info({:hb, time_stamp}, state) do
    Process.send_after(self(), {:hb, time_stamp}, @hb_interval)
    data = [%{topic: "hb", data: time_stamp}] |> Jason.encode!()
    {:push, {:text, data}, state}
  end

  def handle_info({:set_status, node, text}, state) do
    data =
      [%{topic: "status/#{node}", data: %{text: text, fill: "red", shape: "ring"}}]
      |> Jason.encode!()

    {:push, {:text, data}, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg, label: "handle_info")
    {:ok, state}
  end
end
