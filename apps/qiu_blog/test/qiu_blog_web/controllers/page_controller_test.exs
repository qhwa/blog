defmodule QiuBlogWeb.PageControllerTest do
  use QiuBlogWeb.ConnCase

  setup(%{conn: conn}) do
    conn = put_req_header(conn, "x-forwarded-proto", "https")
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Qiu's Blog"
  end
end
