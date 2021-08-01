-- title: Thinking in Elixir
-- tags: Elixir

Most developers have previous programming experiences before using Elixir. Some come to Elixir land from an OOP land. In such cases, a shift of programming model is required to master programming in Elixir. In this post, I'm gonna show some common patterns than can help new developers master their Elixir skills.

## pattern matching

Pattern matching is powerful but in many languages there are no supports of it. It can make code more obvious.

```elixir
posts =
  case params do
    %{"tag" => tag} ->
      list_posts_with_tag(tag)

    _ ->
      list_posts()
  end
```
