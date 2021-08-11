defmodule Blog.Core.MarkdownParser do
  @code_block_reg ~r/<pre><code(?: class="(.+)")?>(.+)<\/code><\/pre>/mUs
  @default_language "elixir"

  def parse(lines) do
    html =
      lines
      |> Enum.join("\n")
      |> Markdown.to_html(
        autolink: true,
        fenced_code: true,
        escape: false,
        math: true,
        no_intra_emphasis: true,
        strikethrough: true,
        superscript: true,
        tables: true,
        underline: true
      )

    Regex.replace(@code_block_reg, html, &syntax_highlight/3)
  end

  defp syntax_highlight(code, "", content),
    do: syntax_highlight(code, @default_language, content)

  defp syntax_highlight(code, "language-" <> lang, content),
    do: syntax_highlight(code, lang, content)

  defp syntax_highlight(_, lang, content),
    do:
      content
      |> HtmlEntities.decode()
      |> Makeup.highlight(lexer: lang)
end
