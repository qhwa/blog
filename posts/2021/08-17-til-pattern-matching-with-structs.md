-- title: TIL: Pattern Matching With Structs
-- tags: Elixir, pattern matching, TIL

For structs, which are also maps, we can use the `%{}` to match them too. However, if we want to ensure the target is a *struct*, instead of a plain map, we can use [`is_struct/1`](https://hexdocs.pm/elixir/Kernel.html#is_struct/1) or [`is_struct/2`](https://hexdocs.pm/elixir/Kernel.html#is_struct/2) guard.

Today I learned that we can also use `%module{}` pattern after Elixir v1.3.0. Here `module` is a variable, and can be a certain value holding the struct name, or `_` for any.

Let's say we have a `User` module:

```elixir
iex> defmodule User do      
...>   defstruct [:age, :name]
...> end
```

We can use `%module{}` pattern to match them:

```elixir
# a struct can be matched with `%_{}`:
iex> %_{} = %User{}
%User{age: nil, name: nil}

# when we only know the module at run time:
iex> target = User
...> %target{} = %User{age: 5}      
%User{age: 5, name: nil}
```

