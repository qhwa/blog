defmodule Blog.Posts do
  alias Blog.Core.Post

  paths =
    Application.compile_env(:blog, :posts_dir)
    |> Path.join("/**/*.md")
    |> Path.wildcard()
    |> Enum.sort()

  posts =
    for path <- paths do
      @external_resource path

      Post.parse_file!(path)
    end

  # @posts Enum.sort_by(posts, & &1.date, {:desc, Date})
  @posts posts

  def all, do: @posts
end
