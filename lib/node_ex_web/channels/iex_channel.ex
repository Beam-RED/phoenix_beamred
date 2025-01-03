defmodule NodeExWeb.IExChannel do
  use Phoenix.Channel

  def join("iex:session", _params, socket) do
    {:ok, socket}
  end

  def handle_in("input", %{"data" => data}, socket) do
    # Send data to the IEx process
    IO.write(data)
    {:noreply, socket}
  end

  def handle_info({:iex_output, output}, socket) do
    push(socket, "output", %{data: output})
    {:noreply, socket}
  end
end
