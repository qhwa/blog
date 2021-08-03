defmodule QiuBlogWeb.PageController do
  use QiuBlogWeb, :controller

  def index(conn, _params) do
    posts = Blog.Posts.all()
    render(conn, "index.html", posts: posts)
  end

  def show(conn, _params) do
    page = conn.assigns.page
    render(conn, "#{page}.html")
  end
end
