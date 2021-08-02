defmodule Blog.Core.MarkdownParser do
  @code_block_reg ~r/<pre><code(?: class="(.+)")?>(.+)<\/code><\/pre>/mUs
  @default_language "elixir"

  def parse(lines) do
    html = lines |> Earmark.as_html!(escape: false)
    Regex.replace(@code_block_reg, html, &syntax_highlight/3)
  end

  defp syntax_highlight(code, "", content),
    do: syntax_highlight(code, @default_language, content)

  defp syntax_highlight(_, lang, content),
    do: Makeup.highlight(content, lexer: lang)
end
