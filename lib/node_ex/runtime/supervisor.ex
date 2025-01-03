defmodule NodeEx.Runtime.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = []

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
