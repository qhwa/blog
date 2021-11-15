-- title: Counting a List? Think Twice!
-- tags: Elixir, List

Counting a list to check whether its size is under certain constraints is the most common mistake I can see:

```elixir
# Don't do:
if length(my_list) > 0, do: something()
```

As we know, regarding a [linked list](https://en.wikipedia.org/wiki/Linked_list) is noncontiguous in memory, getting the length of a list in Elixir/Erlang works in a linear, or `O(n)`, time. So the above code may be slow when `my_list` is large. Do you need to measure the accurate distance to somebody in order to know she's more than a block away? You don't be cause there are better ways.

## What are the alternatives?  

### 1. Use pattern matching if you can

For example:

To check whether a list is empty:

```elixir
def empty_list?(list), do: list == []
```

To check whether a list's length is exactly 1:

```elixir
def one_elem_list?([_]), do: true
def one_elem_list?(_), do: false
```

To check whether a list's length is exactly 2:

```elixir
def two_elem_list?([_, _]), do: true
def two_elem_list?(_), do: false
```

You may wonder what if the number is dynamic. Well, we can write a function for that:

### 2. A "list_not_shorter_than?" function

```elixir
def list_not_shorter_than?([_ | tail], n) when is_integer(n) and n > 0,
  do: list_not_shorter_than?(tail, n - 1)

def list_not_shorter_than?([], len) when is_integer(len),
  do: len <= 0

def list_not_shorter_than?(_, len) when is_integer(len),
  do: true
```

### 3. Use the "Enum.count_until/2" function

We can also use [`Enum.count_until/2`](https://hexdocs.pm/elixir/Enum.html#count_until/2) or [`Enum.count_until/3`](https://hexdocs.pm/elixir/Enum.html#count_until/3) which were introduced into Elixir since 1.12.0.

```elixir
def list_not_shorter_than?(list, n) when is_integer(n) and n >= 0,
  do: Enum.count_until(list, n + 1) >= n
```

It is worth noting that `Enum.count_until` is not for lists, but all enumerable data, e.g. maps. In fact, any data with the implementation of [`Enumerable.count/1` protocol](https://hexdocs.pm/elixir/Enumerable.html#count/1) works.

## Conclustion

Never count a list to check if it is empty.
