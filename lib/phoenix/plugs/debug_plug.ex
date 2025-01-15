defmodule Phoenix.Plugs.DebugPlug do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    IO.inspect(conn.resp_headers, label: "#{opts[:label]}: Response Headers")
    conn
  end
end
