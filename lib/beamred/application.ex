defmodule BeamRED.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BeamRED.Runtime.Supervisor,
      BeamRED.MQTT.Server,
      BeamREDWeb.Telemetry,
      {Phoenix.PubSub, name: BeamRED.PubSub},
      BeamREDWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: BeamRED.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BeamREDWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
