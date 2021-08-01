defmodule Blog.Middleware.DateMeta do
  alias Blog.Core.Post

  def call(%Post{metadata: %{"date" => date} = metadata} = post, _) when is_binary(date) do
    metadata = %{metadata | "date" => Date.from_iso8601!(date)}
    %{post | metadata: metadata}
  end

  def call(post, _),
    do: post
end
