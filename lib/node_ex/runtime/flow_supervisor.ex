defmodule NodeEx.Runtime.FlowSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    name =
      opts[:name] ||
        raise ArgumentError, "the :name option is required when starting FlowSupervisor"

    DynamicSupervisor.start_link(__MODULE__, opts, name: name)
  end

  def start_child(node, opts) do
    spec = {node, opts}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(opts) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: opts)
  end
end
