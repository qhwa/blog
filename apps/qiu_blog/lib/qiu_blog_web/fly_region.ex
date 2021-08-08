defmodule QiuBlogWeb.FlyRegion do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_opts) do
    []
  end

  @impl Plug
  def call(conn, _opts) do
    conn
    |> put_resp_header("x-fly-region", env(:region))
    |> put_resp_header("x-fly-alloc-id", env(:alloc_id))
  end

  defp env(key),
    do:
      Application.get_env(:qiu_blog, :fly, [])
      |> Keyword.get(key)
end
