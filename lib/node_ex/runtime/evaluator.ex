defmodule NodeEx.Runtime.Evaluator do
  use GenServer
  require Logger

  # Client API

  def test() do
    expr =
      NodeEx.Runtime.Expr.new("""
      defmodule Hello do
        def world, do: "Hello world"
      end
      """)

    execute([expr])
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def execute(exprs, opts \\ []) do
    GenServer.call(__MODULE__, {:execute, exprs, opts}, :infinity)
  end

  # Server Callbacks

  @impl true
  def init(state) do
    {:ok, %{caller: nil, refs: []}}
  end

  @impl true
  def handle_call({:execute, exprs, opts}, from, state) do
    refs =
      exprs
      |> Enum.map(fn %NodeEx.Runtime.Expr{} = _expr ->
        make_ref()
      end)

    send(self(), {:start_evaluation, exprs})

    {:noreply, %{state | caller: from, refs: refs}}
  end

  @impl true
  def handle_info({:start_evaluation, exprs}, %{refs: refs} = state) do
    {iex_evaluator, iex_server} =
      IEx.Broker.evaluator()

    Enum.each(Enum.zip(refs, exprs), fn {ref, expr} ->
      do_execute_code(iex_evaluator, iex_server, ref, expr.code)
    end)

    {:noreply, state}
  end

  def handle_info({:iex_reply, ref, test}, %{caller: caller, refs: refs} = state) do
    case List.delete(refs, ref) do
      [] ->
        GenServer.reply(caller, :ok)
        {:noreply, %{state | caller: nil, refs: []}}

      refs ->
        {:noreply, %{state | refs: refs}}
    end
  end

  defp do_execute_code(iex_evaluator, iex_server, ref, code) when is_binary(code) do
    normalized_pid = :erlang.pid_to_list(self())
    normalized_ref = :erlang.ref_to_list(ref)

    code =
      """
      try do
        #{code}
      rescue
        e ->
          send(:erlang.list_to_pid(~c"#{normalized_pid}"), {:iex_reply, :erlang.list_to_ref(~c"#{normalized_ref}"), :rescue})
      else
        result ->
          send(:erlang.list_to_pid(~c"#{normalized_pid}"), {:iex_reply, :erlang.list_to_ref(~c"#{normalized_ref}"), true})
      end
      IEx.dont_display_result()
      """

    send(iex_evaluator, {:eval, iex_server, code, 1, ""})
  end
end
