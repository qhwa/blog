defmodule QiuBlogWeb.FlyRegion do
  @behaviour Plug

  import Plug.Conn
  require Logger

  @impl Plug
  def init(opts) do
    Logger.info(inspect(opts))
    opts
  end

  @impl Plug
  def call(conn, opts) do
    conn
    |> maybe_put_resp_header("x-fly-region", opts[:region])
    |> maybe_put_resp_header("x-fly-alloc-id", opts[:alloc_id])
  end

  defp maybe_put_resp_header(conn, name, value) when is_binary(value),
    do: put_resp_header(conn, name, value)

  defp maybe_put_resp_header(conn, _, _),
    do: conn
end
