defmodule Blog.Core.PostTest do
  use ExUnit.Case, async: true

  alias Blog.Core.Post

  describe "parse_metadata/1" do
    test "it works" do
      raw_content = """
      -- date: 2021-08-01
      -- title: Hello, world!

      test
      """

      parsed =
        raw_content
        |> Post.parse_metadata()

      assert {%{"date" => "2021-08-01", "title" => "Hello, world!"}, ["test"]} == parsed
    end

    test "it cleans empty lines" do
      raw_content = """
      -- foo: bar

      Hello, world!
      """

      parsed =
        raw_content
        |> Post.parse_metadata()

      assert {%{"foo" => "bar"}, ["Hello, world!"]} == parsed
    end

    test "it works with incorrect format" do
      raw_content = """
      -- invalid metadata
      -- foo: bar

      Hello, world!
      """

      parsed =
        raw_content
        |> Post.parse_metadata()

      assert {%{}, raw_content |> String.trim() |> String.split("\n")} == parsed
    end
  end

  describe "parse/1" do
    test "it parses markdown to HTML" do
      raw_content = """
      # Hello, world!
      """

      parsed =
        raw_content
        |> Post.new()
        |> Post.parse()

      assert %Post{body: "<h1>\nHello, world!</h1>\n"} == parsed
    end

    test "it highlighs code blocks" do
      raw_content = """
      ```elixir
      a = 1 + 5
      b = "test"
      ```
      """

      parsed =
        raw_content
        |> Post.new()
        |> Post.parse()

      assert parsed.body ==
               "<pre class=\"highlight\"><code><span class=\"n\">a</span><span class=\"w\"> </span><span class=\"o\">=</span><span class=\"w\"> </span><span class=\"mi\">1</span><span class=\"w\"> </span><span class=\"o\">+</span><span class=\"w\"> </span><span class=\"mi\">5</span><span class=\"w\">\n</span><span class=\"n\">b</span><span class=\"w\"> </span><span class=\"o\">=</span><span class=\"w\"> </span><span class=\"s\">&quot;test&quot;</span></code></pre>\n"
    end

    test "it highlights common code block" do
      raw_content = """
      ```
      1 + 2
      ```
      """

      parsed =
        raw_content
        |> Post.new()
        |> Post.parse()

      assert parsed.body ==
               "<pre class=\"highlight\"><code><span class=\"mi\">1</span><span class=\"w\"> </span><span class=\"o\">+</span><span class=\"w\"> </span><span class=\"mi\">2</span></code></pre>\n"
    end

    test "it doesn't hightlight inline code" do
      raw_content = """
      `1 + 2`
      """

      parsed =
        raw_content
        |> Post.new()
        |> Post.parse()

      assert parsed.body == "<p>\n<code class=\"inline\">1 + 2</code></p>\n"
    end
  end
end
