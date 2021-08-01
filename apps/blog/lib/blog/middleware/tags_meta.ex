defmodule Blog.Middleware.TagsMeta do
  alias Blog.Core.Post

  def call(%Post{metadata: %{"tags" => tags} = metadata} = post, _) when is_binary(tags) do
    metadata = %{metadata | "tags" => String.split(tags, ~r/,\s*/)}
    %{post | metadata: metadata}
  end

  def call(post, _),
    do: post
end
