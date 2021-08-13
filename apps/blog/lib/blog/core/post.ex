defmodule Blog.Core.Post do
  @moduledoc """
  Core abstraction for posts.
  """

  alias __MODULE__

  defstruct [:id, :title, :date, :body, :tags, :description, :author, :metadata]

  @type t :: %Post{
          id: String.t(),
          title: String.t(),
          description: String.t(),
          date: Date.t(),
          body: String.t(),
          author: String.t(),
          tags: [String.t()],
          metadata: map()
        }

  def parse_file!(path) do
    [full_path, year, month, day, id] = Regex.run(~r/^.*(\d{4})\/(\d{2})-(\d{2})-(.*)\.md$/, path)

    post =
      full_path
      |> File.read!()
      |> new()
      |> parse()

    %{
      post
      | date: Date.from_iso8601!("#{year}-#{month}-#{day}"),
        id: id
    }
  end

  def new(body) do
    %Post{body: body}
  end

  @spec parse(t()) :: t()
  def parse(%Post{} = post) do
    {attributes, metadata, rest_body} = parse_metadata(post.body)

    %Post{post | metadata: metadata, body: parse_body(rest_body)}
    |> struct(attributes)
  end

  @spec parse_metadata(String.t()) :: {map(), [String.t()]}
  def parse_metadata(body) do
    {parsed, rest_body} =
      body
      |> String.trim()
      |> String.split("\n")
      |> do_parse_metadata(%{})

    top_levels = ~w[description author title tags] |> MapSet.new()

    {attributes, metadata} =
      Enum.split_with(parsed, fn {k, _} ->
        MapSet.member?(top_levels, k)
      end)

    attributes =
      attributes
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    {attributes, metadata, rest_body}
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
        parse_meta(key, value)

      _ ->
        nil
    end
  end

  defp do_parse_metadata_inline(_),
    do: nil

  defp parse_meta("tags", value),
    do: {"tags", String.split(value, ",", trim: true)}

  defp parse_meta(key, value),
    do: {key, parse_body([value])}

  defp rest_of_body(rest),
    do: rest |> Enum.drop_while(&(&1 =~ ~r/\A\s*\Z/))

  defp parse_body(raw_body),
    do: raw_body |> markdown_to_html()

  defp markdown_to_html(markdown),
    do: Blog.Core.MarkdownParser.parse(markdown)

  @doc """
  Get metadata values under a given key
  """
  def metadata_values(post, name) do
    for {^name, value} <- post.metadata, do: value
  end
end
