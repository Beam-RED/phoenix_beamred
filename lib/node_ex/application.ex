defmodule NodeEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NodeEx.Storage,
      NodeEx.Runtime,
      # TODO start evaluator from runtime
      NodeEx.Runtime.Evaluator,
      {DynamicSupervisor, name: NodeEx.Runtime.FlowsSupervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: NodeEx.Runtime.Registry},
      NodeExWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:node_ex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NodeEx.PubSub},
      NodeExWeb.Channel.Server,
      # Start a worker by calling: NodeEx.Worker.start_link(arg)
      # {NodeEx.Worker, arg},
      # Start to serve requests, typically the last entry
      NodeExWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NodeEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NodeExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
