defmodule Blog.Posts do
  alias Blog.Core.Post

  @posts Application.compile_env(:blog, :posts_dir)
         |> Path.join("*.md")
         |> Path.wildcard()
         |> Stream.map(&File.read!/1)
         |> Stream.map(&Post.new/1)
         |> Stream.map(&Post.parse/1)
         |> Enum.to_list()

  def all, do: @posts
end
