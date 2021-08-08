-- title: Landing on Elixir: Pattern Matching
-- tags: Elixir, pattern matching

Elixir is most likely not the first programming language for a programmer today. Most developers have previous programming experiences before using Elixir. Some come to this new place from an OOP land. In such cases, to master programming in Elixir requires a shift of programming models. In this post, I will show some common patterns that can help new developers hone their Elixir skills.

Pattern matching is one of the most exciting features of a functional programming language.

### What is pattern matching?

In Elixir, `=` is a match asserting operator instead of variable assigning. It takes left and right hand parts. If they match, the assertion is successful, and the result value of the expression is the right part.

```elixir
iex> :foo = :foo
:foo

iex> [1, 2] = [1, 2]
[1, 2]

iex> %{foo: "bar"} = %{foo: "bar", foz: "baz"}
%{foo: "bar", foz: "baz"}
```
Otherwise, if not matched, it is considered unsuccessful and a `MatchError` will be raised:

```elixir
iex> :foo = "foo"
** (MatchError) no match of right hand side value: "foo"
```

Pattern matching has a side effect. If the left hand part has some unbind variable names, the corresponding matched values will be bound to them, respectively:

```elixir
iex> {:ok, %{age: age, name: name}} = {:ok, %{age: 8, name: "Q"}}
{:ok, %{age: 8, name: "Q"}}

iex> age
8

iex> name
"Q"
```

That's a brief introduction to pattern matching. There are a few things make it awesome.

### Pattern matching makes your code expressive.

When you describe the requirement with pattern matching, you've almost finished programming. Let's take an example.

![family demand](/post-images/family-demand.png)

For example, your partner asks you to buy something from the market on your way home:

> If you come home early today, please buy some fruits and vegetables from the market. I need *a bag of potatoes*. Also, buy *some apples* and *grapes* if you see them.

Here's the code for it:

```elixir
def what_to_buy(now, demands, item_seen) do
  ...
end

now = ~N[2021-08-01 20:45:12.623713]

demands = %{
  "potato" => 1,
  "apple" => :some,
  "grape" => :some
}

items_seen = %{
  "potato" => 0.5,
  "apple" => 15
  "egg" => 1
}

what_to_buy(now, demands, items_seen)
#=> %{
#     "potato" => {:error, :sold},
#     "apple" => {:ok, 2},
#     "grape" => {:error, :not_seen}
#   }
```

Now let's implement the function `what_to_buy/3`.

We may write something straightforward with the standard logic controls: `if` and `cond`.

```elixir
def what_to_buy(now, demands, item_seen) do
  unless too_late?(now) do
    for {item, demand_quantity} <- demands, into: %{} do
      cond do
        item_seen[item] == nil ->
          {item, {:error, :not_seen}}

        not enough?(item_seen, item, demand_quantity) ->
          {item, {:error, :sold}}

        true ->
          {item, {:ok, determine_quanity(item_seen, item, demand_quantity)}}
      end
    end
  end
end

defp too_late?(t),
  do: t.hour < 21 

defp enough?(items_seen, item, demand_quanity) do
  left = items_seen[item]

  if demand_quanity == :some do
    left > 0
  else
    left >= demand_quanity
  end
end

defp determine_quanity(item_seen, item, demand_quanity) do
  if demand_quanity == :some do
    :rand.uniform(item_seen[item] - 1) + 1
  else
    demand_quanity
  end
end
```

In constract, here's the pattern matching version:

```elixir
defguard is_enough(left, x) when is_number(left) and is_number(x) and left >= x
defguard is_sold(left, x) when is_number(left) and is_number(x) and left < x

# first pattern: buy nothing when too late
def what_to_buy(%DateTime{hour: h}, _, _) when h > 21,
  do: nil

def what_to_buy(_, demands, item_seen) do
  for {item, demand_quanity} <- demands, into: %{} do
    result =
      case {item_seen[item], demand_quanity} do
        # second pattern: available and demand is "some"
        {left, :some} when is_number(left) ->
          {:ok, :rand.uniform(left - 1) + 1}

        # third pattern: available and fixed demanded quanlity
        {left, x} when is_enough(left, x) ->
          {:ok, x}

        # fourth pattern: not enough on the market
        {left, x} when is_sold(left, x) ->
          {:error, :sold}

        # fifth pattern: not seen on the market
        {nil, _} ->
          {:error, :not_seen}
      end

    {item, result}
  end
end
```

As you can see, **the pattern matching version is much easier to reflect the actual requirement.**

And there's more about pattern matching.

### Pattern matching is performant

because...

1. Pattern matching will be optimized by compiler [<sup>1</up>](https://erlang.org/doc/efficiency_guide/functions.html#pattern-matching).
2. Pattern matching can avoid creating temporary strings when matching against binaries [<sup>2</sup>](https://erlang.org/doc/efficiency_guide/binaryhandling.html#match_context).

### Pattern matching is excellent at decomposing data structures

Here are some basic examples.

```elixir
iex> [a, b | rest] = [1, 2, 3, 4]
...> a
1

iex> b
2

iex> rest
[3, 4]
```

Decomposing a nested map struct:

```elixir
iex> response = %{
...>   "data" => %{
...>     "order1" => %{"success" => true}
...>   }
...> }
...>
...> %{"data" => %{"result" => %{"order1" => %{"success" => succeeded}}}} = response
...>
...> succeeded
true
```

Decomposing binary data:

```elixir
iex> data = "\x03ABCfooooo"
...> <<content_len, "ABC", content::binary-size(content_len), _::binary>> = data

...> content_len
3

...> content
"foo"
```

Pattern matching makes decoding binary data so enjoyable. I love processing data in Elixir, and that's one of the fundamental reasons.

#### Special tip: pattern matching with lists

![linked list](/post-images/linked-list.png)

Some new developers think list in Elixir/Erlang as equivalent to Array in JavaScript. While an array has a `length` property that allows us to get its length efficiently, a list doesn't. The following code is considered inefficient:

```elixir
# Do not do:
def handle_something(my_list) do
  if length(my_list) > 0 do
    do_something_with(my_list)
  else
    do_another_thing()
  end
end
```

The problem is that lists are linked and sparse in memory. It's `O(1)` to get the head of the list or get the rest which is another list. When the rest is an empty list `[]`, we know we have reached the end of the list. Getting the length of a list is of `O(n)` complexity of time.

So, we can rewrite the above example to:

```elixir
def handle_something(my_list),
  do: do_something_with(my_list)

defp do_something_with([]),
  do: do_another_thing()

defp do_something_with([hd | rest]),
  do: ...
```

Pattern matching is the basis of recursion in Erlang.

```elixir
def foo([_head | _tail]) # <- non_empty_list
def foo([])              # <- empty_list
```

This will lead us to an interesting topic: list and recursion. We'll talk about it later posts since this is already getting long.


## Conclusion

Pattern matching is something so powerful yet an enjoyable way to structure our code. Try it if you haven't. I bet you'll like it.


#### Further reading

* [Video tutorial of pattern matching in Elixir](https://www.poeticoding.com/the-beauty-of-pattern-matching-in-elixir/)
* [Pin operator](https://elixir-lang.org/getting-started/pattern-matching.html#the-pin-operator) for pattern matching