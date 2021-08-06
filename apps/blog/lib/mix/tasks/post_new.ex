defmodule Mix.Tasks.Post.New do
  @moduledoc """
  Create a new post.

  ## Usage:

  ```sh
  mix post.new 'my post title'
  ```
  """
  @doc false
  def run(args) do
    case parse_args(args) do
      {_options, [title], []} ->
        title
        |> to_file_path()
        |> write_post(title)

      _ ->
        print_usage()
    end
  end

  defp parse_args(args),
    do: OptionParser.parse(args, strict: [])

  defp print_usage do
    """
    usage:

      mix post.new "my post title"
    """
    |> IO.puts()
  end

  defp to_file_path(title) do
    {date, _} = :calendar.local_time()
    post_file(date, title)
  end

  defp post_file({year, month, date}, title) do
    Path.join([
      Application.get_env(:blog, :posts_dir, "."),
      year |> to_string(),
      [
        month |> to_string() |> String.pad_leading(2, "0"),
        "-",
        date |> to_string() |> String.pad_leading(2, "0"),
        "-",
        join_title(title),
        ".md"
      ]
    ])
  end

  defp join_title(title),
    do:
      Regex.scan(~r/\w+/u, title)
      |> Stream.map(&hd/1)
      |> Stream.map(&String.downcase/1)
      |> Enum.join("-")

  defp write_post(file, title) do
    file |> Path.dirname() |> File.mkdir_p()
    File.write(file, content(title))
  end

  defp content(title) do
    """
    -- title: #{title}
    """
  end
end
