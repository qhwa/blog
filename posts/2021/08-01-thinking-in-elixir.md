-- title: Thinking In Elixir (1): Pattern Matching
-- tags: Elixir, pattern matching

Most developers have previous programming experiences before using Elixir. Some come to Elixir land from an OOP land. In such cases, a shift of programming models is required to master programming in Elixir. In this post, I'm gonna show some common patterns that can help new developers master their Elixir skills.

Pattern matching is probably new to many who came from the land of the OOP world. Elixir does have `if`, `unless`, `else`, and `cond` which allows you to do a traditional way of controlling. But in most cases, pattern matching is a better choice if possible.

### Pattern matching makes your code expressive.

When you describe the requirement with pattern matching, you've almost finished programming. Let's take an example.

![family demand](/post-images/family-demand.png)

For example, your partner asks you to buy something from the market on your way home:

> If you come home early today, please buy some fruits and vegetables from the market. I need *a bag of potatoes*. Also, buy *some apples* and *grapes* if you see them.

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

We may write something straightforward with `if` and `cond` which are common logic controls in other languages.

```elixir
def what_to_buy(now, demands, item_seen) do
  if now.hour < 21 do
    for {item, quantity} <- demands, into: %{} do
      cond do
        item_seen[item] == nil ->
          {item, {:error, :not_seen}}

        not enough?(item_seen, item, quantity) ->
          {item, {:error, :sold}}

        true ->
          {item, {:ok, determine_quanity(item_seen, item, quantity)}}
      end
    end
  end
end

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

        # third pattern: available and fixed demand
        {left, x} when is_enough(left, x) ->
          {:ok, x}

        # fourth pattern: not enough
        {left, x} when is_sold(left, x) ->
          {:error, :sold}

        # fifth pattern: not seen
        {nil, _} ->
          {:error, :not_seen}
      end

    {item, result}
  end
end
```

As you can see, **the pattern matching version is much easier to reflect the original requirement.**

But there's more about pattern matching.

### Pattern matching is performant

1. Pattern matching will be optimized by compiler [<sup>1</up>](https://erlang.org/doc/efficiency_guide/functions.html#pattern-matching).
2. Pattern matching can avoid creating temporary strings when matching against binaries [<sup>2</sup>](https://erlang.org/doc/efficiency_guide/binaryhandling.html#match_context).

### Pattern matching with lists

![linked list](/post-images/linked-list.png)

Some new developers think list in Elixir/Erlang as equivalent to Array in JavaScript. While an array has a `length` property that allows us to get the length of it efficiently, a list doesn't. The following code is considered inefficient:

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

So, the above example can be rewritten to:

```elixir
def handle_something(my_list),
  do: do_something_with(my_list)

defp do_something_with([]),
  do: do_another_thing()

defp do_something_with([hd | rest]),
  do: ...
```

This will lead us to an interesting topic: list and recursion. We'll talk about it later posts since this is already getting long.

Before that, just a note, pattern matching against a list can be like destructing in JavaScript:

```elixir
[first, second, third | rest] = [:a, "b", 50, "foo", "bar"]
```

And also, pattern matching can be used check if a list is empty:

```elixir
[_head | _tail] = non_empty_list
[] = empty_list
```

### Pattern matching with binaries

One exciting thing about pattern matching is that binaries can be matched too. This makes decoding binary data such an enjoyment. I love processing data in Elixir and that's one of the strong reasons.

If you're interested, I wrote another post on binaries: [Questions for BitString, Binary, Charlist, and String in Elixir — Part 2: Binary (or bytes)](https://qhwa-85848.medium.com/questions-for-bitstring-binary-charlist-and-string-in-elixir-part-2-binary-or-bytes-687315789030)


To be continued:

* comparison
* List and recursion
* small single-purpose and pure functions
* Try & Catch.
