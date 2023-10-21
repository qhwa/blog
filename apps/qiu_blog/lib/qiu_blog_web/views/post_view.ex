defmodule QiuBlogWeb.PostView do
  alias Blog.Core.Post
  use QiuBlogWeb, :view

  def render_acknowlegement(post) do
    case Post.metadata_values(post, "acknowledgements") do
      [_ | _] = contents ->
        render("acknowledgements.html", contents: contents)

      _ ->
        nil
    end
  end

  def render("404.html", _assigns) do
    raw("""
    <h1>Error: 404</h1>
    <p>Sorry, the page you were looking for could not be found.</p>
    """)
  end
end
