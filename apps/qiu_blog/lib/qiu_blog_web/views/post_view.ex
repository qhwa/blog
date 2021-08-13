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
end
