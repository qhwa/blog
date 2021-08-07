defmodule QiuBlogWeb.FlyRegion do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_opts) do
    %{
      region: System.get_env("FLY_REGION"),
      alloc_id: System.get_env("FLY_ALLOC_ID")
    }
  end

  @impl Plug
  def call(conn, %{region: region, alloc_id: alloc_id}) do
    conn
    |> maybe_put_resp_header("x-fly-region", region)
    |> maybe_put_resp_header("x-fly-alloc-id", alloc_id)
  end

  defp maybe_put_resp_header(conn, name, value) when is_binary(value),
    do: put_resp_header(conn, name, value)

  defp maybe_put_resp_header(conn, _, _),
    do: conn
end
