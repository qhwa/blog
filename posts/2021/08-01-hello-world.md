-- title: Hello, world!
-- tags: blog

![Hello, world](/post-images/hello-world.png)

I just built another blog. Given I already have two blogs ([pnq](http://q.pnq.cc) and [medium](https://medium.com/@qhwa-85848/)), why would I build another blog engine on my own?

Well, it's because I would like to have some fun playing Elixir. My original blog (pnq) was built on top of jekyll and second on Medium.

This time, I would like to do some experiments on Elixir programming. So blog platform is defintely a good target.

I was encouraged by [Dashbit's great post](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) of rolling out one's own blog engine with Elixir. I was thinking, man this is cool, and I want to try it myself!

**It's a perfect practice to programming Elixir!**

What excites me most is that I can use meta-programming to directly compile data into code. The post you're reading right now has been read and processed by the compiler. A set of rules, namely Markdown parsing and syntax highlight at this moment, have been applied to the original content. Then all the posts were compiled into a module:

```
defmodule Blog.Posts do
  alias Blog.Core.Post

  for app <- ~w[makeup makeup_elixir makeup_c makeup_html]a do
    Application.ensure_all_started(app)
  end

  paths =
    Application.compile_env(:blog, :posts_dir)
    |> Path.join("/**/*.md")
    |> Path.wildcard()
    |> Enum.sort()

  posts =
    for path <- paths do
      @external_resource path

      Post.parse_file!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def all, do: @posts
end
```

Data lives in the code but no other places. This works perfectly for me, because I wrote no more than 3 posts every year. LOL

I spent one day to write it and have it running. I'm so pleased now.
