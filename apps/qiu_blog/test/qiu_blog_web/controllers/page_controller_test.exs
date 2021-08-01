defmodule QiuBlogWeb.PageControllerTest do
  use QiuBlogWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Qiu's Blog"
  end
end
