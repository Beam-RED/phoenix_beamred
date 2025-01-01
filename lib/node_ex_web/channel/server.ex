defmodule NodeExWeb.Channel.Server do
  @moduledoc false
  use GenServer

  require Logger

  defstruct connections: []

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def add_connection(client) do
    GenServer.call(__MODULE__, {:add_connection, client})
  end

  def remove_connection(client) do
    GenServer.call(__MODULE__, {:remove_connection, client})
  end

  def subscribe(client, topic) do
    GenServer.call(__MODULE__, {:subscribe, client, topic})
  end

  def publish(topic, data) do
    GenServer.call(__MODULE__, {:publish, topic, data})
  end

  def handle_call({:add_connection, client}, _from, state) do
    new_state = %{state | connections: [client | state.connections]}
    {:reply, :ok, new_state}
  end

  def handle_call({:remove_connection, client}, _from, state) do
    new_connections = Enum.reject(state.connections, fn c -> c == client end)
    new_state = %{state | connections: new_connections}
    {:reply, :ok, new_state}
  end

  def handle_call({:subscribe, client, topic}, _from, state) do
    {:rely, :ok, state}
  end

  def handle_call({:publish, topic, data}, _from, state) do
    Enum.each(state.connections, fn connection ->
      send(connection, {:publish, topic, data})
    end)

    {:reply, :ok, state}
  end
end
