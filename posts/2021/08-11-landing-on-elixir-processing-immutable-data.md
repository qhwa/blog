-- title: Landing on Elixir: Processing Immutable Data
-- tags: Elixir, data struct, immutable
-- description: Common patterns of processing data in Elixir.

This post is the second one of the "Landing on Elixir" serial which aims to help newcomers from another programming land hone their Elixir programming skills:

- [Landing on Elixir: Pattern Matching](./landing-on-elixir-pattern-matching)
- Landing on Elixir: Processing Immutable Data

### Immutable Data

Immutable data is not a new concept. It is a fundament of functional programming. To Erlang and Elixir, it is also the core concept to support the process-oriented language design. Only if the data is immutable can we safely process it in multiple processes parallelly.

But this may not be obvious at first, and you may struggle in dealing with data, especially in a deeply nested shape.

Technically, we can not **update** the data. What we can do is using a function to process it, returning new data, leaving the original data unchanged, as the following picture depicts:

![a data processing function](/post-images/a-data-processing-function.png)

The original data (O) is still available after processed, and the new output data (O') is different. They can share some common parts for better performance, but they are two objects.

The concept is simple, but you need to be used to it because it leads to different processing patterns than mutable data.

<details>
<summary><h3>Updating a value in a map</h3></summary>

Let's assume you have a piece of data like this:

```elixir
data = %{"id" => "ABCDEF"}
```

And you need to lower case the id value (`"ABCDEF"`), with all other fields remaining the same. The expected result is:

```elixir
iex> process.(data)
%{"id" => "abcdef"}
```

Solutions:

You can achieve it by using the `|` (map specific update) operator:

```elixir
process = fn %{"id" => id} = data ->
  %{data | "id" => String.downcase(id)}
end
```

or [`Map.update!/3`](https://hexdocs.pm/elixir/Map.html#update!/3)

```elixir
process = fn data ->
  Map.update!(data, "id", &String.downcase/1)
end
```

There are other helpful functions provided by the Map module, e.g.

- `replace/3` for replacing a value under an existing key
- `update/4` for updating a value based on its original value and setting a default if not already presenting
- `put/3` for setting a key, value pair no matter if it is already in the map
- `put_new/3` for setting a new key and its value

You can choose the right function to use depending on whether the key is already in the map and if the update is based on the original value.
</details>

<details>
<summary><h3>Changing the key name in a map</h3></summary>

What if you need to change the key's name? For example, for the following map, to change the key name from `_id` to `id`:

```elixir
# from:
%{"_id" => "example"}

# to:
%{"id" => "example"}
```

[`Map.pop/3`](https://hexdocs.pm/elixir/Map.html#pop/3) is a good fit here:

```elixir
fn data ->
  # first we remove the old key ("_id"), and save its value
  {id_value, temp_data} = Map.pop(data, "_id")

  # optionally,restructure we may compute a new value based on the
  # original value:
  #
  # id_value = process_id_value(id_value)

  # then we put back the id value under a new key ("id")
  Map.put(temp_data, "id", id_value)
end
```
</details>

<details>
<summary><h3>Updating a nested map</h3></summary>

What if the target is not at the top level of the map? For example, to downcase the id value in the following data:

```elixir
%{
  a: %{
    b: %{
      c: %{
        "id" => "EXAMPLE" # <- change it to "example"
      }
    }
  }
}
```

One solution can be:

```elixir
fn data ->
  Map.update!(data, :a, fn data_a ->
    Map.update!(data_a, :b, fn data_b ->
      Map.update!(data_b, :c, fn data_c ->
        Map.update!(data_c, "id", &String.downcase/1)
      end)
    end)
  end)
end)
```

Looks too complex? We can employ [`Kernel.update_in/2`](https://hexdocs.pm/elixir/Kernel.html#update_in/2) to simplify it:

```elixir
fn data ->
  update_in(data.a.b.c["id"], &String.downcase/1)
end
```
</details>

<details>
<summary><h3>Updating a list</h3></summary>

Let's say we want to convert the second item in the list, upcasing its value:

```elixir
# before
["a", "b", "c", "d"]

# after
["a", "B", "c", "d"]
```
We can use [`List.update_at/3`](https://hexdocs.pm/elixir/List.html#update_at/3) to update any data at a given index in a list:

```elixir
fn data ->
  List.update_at(data, 1, &String.upcase/1)
end
```

The before and after lists look like this:

![updating a list](/post-images/updating-a-list.png)

This is expensive when the list is big because we may reconstructure n heads again to generate the new list.
</details>

<details>
<summary><h3>Updating all fields recursively</h3></summary>

In some cases, we don't know exactly where the position of the target is. For example, let's say we want to replace all the image URLs in the following data, replacing `"example.com"` to `"image.example.com"`:

```elixir
# orignal data
%{
  "data" => %{
-   "logo" => "http://example.com/logo.png",
+   "logo" => "http://image.example.com/logo.png",
    "articles" => [
      %{
        "title" => "Article 1",
        "image" => %{
-         "url" => "http://example.com/1.png"
+         "url" => "http://image.example.com/1.png"
        }
      },
      %{
        "title" => "Article 2",
        "image" => %{
-         "url" => "http://example.com/2.png"
+         "url" => "http://image.example.com/2.png"
        }
      }
    ]
  }
}
```

We can use `Enum.map/2` to update recursively.

For a map, we iterate all its `{key, value}` pairs:

```elixir
def process(map) when is_map(map),
  do: map
      |> Enum.map(fn {key, value} ->
        {key, process(value)}
      end)
      |> Enum.into(%{})
```

or

```elixir
def process(map) when is_map(map) do
  for {key, value} <- map, into: %{} do
    {key, process(value)}
  end
end
```

For a list, we iterate all items inside it:

```elixir
def process(list) when is_list(list),
  do: Enum.map(list, &process/1)
```

For a binary, we apply the replacing on it:

```elixir
def process(url) when is_binary(url),
  do: String.replace(
    url,
    "http://example.com/",
    "http://image.example.com/"
  )
```

Otherwise, we just return the original data:

```elixir
def process(other), do: other
```

So the final function would be:

```elixir
def process(map) when is_map(map) do
  for {key, value} <- map, into: %{} do
    {key, process(value)}
  end
end

def process(list) when is_list(list),
  do: Enum.map(list, &process/1)

def process(url) when is_binary(url),
  do:
    String.replace(
      url,
      "http://example.com/",
      "http://image.example.com/"
    )

def process(other), do: other
```

This, of course is not complete because other data structs can be iterated, and you can use this pattern to transform your data’s shape recursively.
</details>

## Conclusion

We have discussed several patterns to update some parts of the data. I hope they are helpful to you!

## Further reading

* [Map module documentation](https://hexdocs.pm/elixir/Map.html)
* [List module documentation](https://hexdocs.pm/elixir/List.html)


