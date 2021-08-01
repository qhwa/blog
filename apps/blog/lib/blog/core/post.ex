defmodule Blog.Core.Post do
  @moduledoc """
  Core abstraction for posts.
  """

  alias __MODULE__

  defstruct [:raw_content, :html_content, metadata: %{}]

  @type t :: %Post{
          raw_content: String.t(),
          html_content: String.t(),
          metadata: %{binary() => term()}
        }

  @type middleware :: module()
  @type parse_option :: {:middlewares, [middleware()]}
  @type parse_options :: [parse_option()]

  @middlewares [
    Blog.Middleware.DateMeta,
    Blog.Middleware.TagsMeta
  ]

  def new(raw_content) do
    %Post{raw_content: raw_content}
  end

  @spec parse(t(), parse_options()) :: t()
  def parse(%Post{} = post, opts \\ []) do
    {metadata, rest_body} = parse_metadata(post)

    post = %Post{
      post
      | metadata: metadata,
        html_content: parse_body(rest_body)
    }

    middlewares = Keyword.get(opts, :middlewares, @middlewares)

    Enum.reduce(middlewares, post, & &1.call(&2, opts))
  end

  @spec parse_metadata(t()) :: t()
  def parse_metadata(%Post{raw_content: raw_content}) do
    raw_content
    |> String.split("\n")
    |> do_parse_metadata(%{})
  end

  defp do_parse_metadata([], metadata),
    do: {metadata, []}

  defp do_parse_metadata([line | rest], metadata) do
    case do_parse_metadata_inline(line) do
      {key, value} ->
        metadata = Map.put(metadata, key, value)
        do_parse_metadata(rest, metadata)

      nil ->
        {metadata, rest_of_body([line | rest])}
    end
  end

  defp do_parse_metadata_inline(<<"-- ", line::binary>>) do
    case String.split(line, ": ", parts: 2, trim: true) do
      [key, value] ->
        {key, value}

      _ ->
        nil
    end
  end

  defp do_parse_metadata_inline(_),
    do: nil

  defp rest_of_body(rest),
    do: rest |> Enum.drop_while(&(&1 =~ ~r/\A\s*\Z/))

  defp parse_body(raw_body),
    do: raw_body |> markdown_to_html()

  defp markdown_to_html(markdown),
    do: Blog.Core.MarkdownParser.parse(markdown)
end
