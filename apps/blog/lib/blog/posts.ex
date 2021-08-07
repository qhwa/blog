defmodule Blog.Posts do
  alias Blog.Core.Post

  for app <- ~w[makeup makeup_elixir makeup_c makeup_html]a do
    Application.ensure_all_started(app)
  end

  posts_dir = Application.compile_env(:blog, :posts_dir)

  @external_resource Path.join(posts_dir, "info.txt")

  paths =
    posts_dir
    |> Path.join("/**/*.md")
    |> Path.wildcard()
    |> Enum.sort(:desc)

  posts =
    for path <- paths do
      @external_resource path

      Post.parse_file!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def all, do: @posts

  def all_with_tag(tag),
    do: @posts |> Enum.filter(&Enum.member?(&1.tags, tag))

  def get(id),
    do: @posts |> Enum.find(&(&1.id == id))
end
