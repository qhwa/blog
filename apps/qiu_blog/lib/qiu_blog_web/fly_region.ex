defmodule QiuBlogWeb.FlyRegion do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, opts) do
    conn
    |> put_resp_header("x-fly-region", opts[:region] || "UNKNOWN")
    |> put_resp_header("x-fly-alloc-id", opts[:alloc_id] || "UNKNOWN")
  end
end
