defmodule QiuBlogWeb.PostController do
  use QiuBlogWeb, :controller

  action_fallback :page_not_found

  @metadata Application.compile_env(:qiu_blog, :metadata, [])

  def index(conn, params) do
    posts =
      case params do
        %{"tag" => tag} ->
          Blog.Posts.all_with_tag(tag)

        _ ->
          Blog.Posts.all()
      end

    metadata = %{
      og: [
        title: @metadata[:title],
        image: @metadata[:image],
        description: @metadata[:description]
      ],
      twitter: [
        site: @metadata[:twitter_site],
        card: @metadata[:twitter_card_type],
        title: @metadata[:title],
        description: @metadata[:description],
        image: @metadata[:image]
      ]
    }

    render(conn, "index.html", posts: posts, metadata: metadata)
  end

  def show(conn, %{"id" => id}) do
    with %{} = post <- Blog.Posts.get(id) do
      image = first_image(post.body)

      metadata = %{
        og: [
          title: post.title,
          image: image,
          description: post.description
        ],
        twitter: [
          site: @metadata[:twitter_site],
          card: @metadata[:twitter_card_type],
          title: post.title,
          description: post.description,
          image: image
        ]
      }

      render(
        conn,
        "show.html",
        post: post,
        title: post.title,
        metadata: metadata
      )
    end
  end

  defp first_image(body) do
    case Regex.run(~r/<img src="(.+)"/U, body) do
      [_, src] ->
        Routes.static_url(QiuBlogWeb.Endpoint, src)

      _ ->
        nil
    end
  end

  defp page_not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render("404.html")
  end
end
