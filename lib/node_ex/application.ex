defmodule NodeEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NodeEx.Runtime.Supervisor,
      NodeEx.MQTT.Server,
      NodeExWeb.Telemetry,
      {Phoenix.PubSub, name: NodeEx.PubSub},
      NodeExWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NodeEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NodeExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
