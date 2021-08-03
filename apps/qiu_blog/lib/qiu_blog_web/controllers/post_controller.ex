defmodule QiuBlogWeb.PostController do
  use QiuBlogWeb, :controller

  def index(conn, params) do
    posts =
      case params do
        %{"tag" => tag} ->
          Blog.Posts.all_with_tag(tag)

        _ ->
          Blog.Posts.all()
      end

    render(conn, "index.html", posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = Blog.Posts.get(id)
    render(conn, "show.html", post: post, title: post.title)
  end
end
