-- title: Landing on Elixir: Processing Immutable Data
-- tags: Elixir, data struct, immutable
-- description: Second of the series "Landing on Elixir", with some patterns of processing data in Elixir.
-- acknowledgements: I want to thank <a rel="noreferrer" href="https://github.com/princemaple">Po Chen</a> for reviewing this post and providing valuable feedback.


<summary class="note">
This post is the second one of the "Landing on Elixir" series, which aims to help newcomers from another programming land hone their Elixir programming skills:

- [Landing on Elixir: Pattern Matching](./landing-on-elixir-pattern-matching)
- Landing on Elixir: Processing Immutable Data

</summary>

### The pain of processing immutable data

The other day I saw a block of code whose author had struggled in processing the data. Here’s a simplified version of it:

```elixir
defp transform_store(store) do
  retailers = store["retailers"]
  logo_url = retailers["logoUrl"]

  retailers =
    if logo_url != nil do
      retailers = Map.delete(retailers, "logoUrl")
      logo_url = @prefix <> logo_url
      Map.put(retailers, "logoUrl", logo_url)
    else
      retailers
    end

  retailer_id = retailers["id"]
  company = retailers["company"]
  company_map_id = company["id"]
  company = Map.delete(company, "id")
  company = Map.put(company, "_id", company_map_id)
  retailers = Map.delete(retailers, "id")
  retailers = Map.delete(retailers, "company")
  retailers = Map.put(retailers, "_id", retailer_id)
  retailers = Map.put(retailers, "company", company)

  store_map_id = store["id"]
  store = Map.delete(store, "id")
  store = Map.delete(store, "retailers")
  store = Map.put(store, "retailer", retailers)
  store = Map.put(store, "_id", store_map_id)

  store
end
```

![omg](/post-images/omg.png)

I constrained to figure out that what it does is to transform some data with the following shape:

```elixir
%{
  "point" => [_latitude, _longitude],
  "id" => "store-id",
  "retailers" => %{
    "id" => "retailer-id",
    "logoUrl" => "/path/to/logo",
    "company" => %{
      "id" => "company-id"
    }
  }
}
```

into: 

```elixir
%{
  "_id" => "store-id",

  # note that `retailers` has been renamed to
  # `retailer` (singular form)
  "retailer" => %{
    "_id" => "retailer-id",
    "logoUrl" => @prefix <> "/path/to/logo",
    "company" => %{
      "_id" => "company-id"
    }
   }
}
```

I felt the struggle in writing the code because the author was not familiar with APIs provided by Elixir.

But indeed, processing immutable data in Elixir can be more fun. In this article, we'll discuss some methods to process data in Elixir, and see how this code can be written into maintainable and reusable code.

To warm-up, let's discuss some basic concepts of processing immutable data.

### Immutable Data

Immutable data is not a new concept. It is a fundament of functional programming. But this may not be obvious at first, and we may struggle in dealing with data, especially in a deeply nested shape.

Technically, we can not **update** the data. What we can do is using a function to **transform** it into a new piece of data, leaving the original data unchanged, as the following depicts:

![a data processing function](/post-images/a-data-processing-function.png)

The original data (O) is still available after processed, and the new output data (O') is different. They can share some common parts for better performance, but they are two objects.

The concept is simple, but we need to get used to it because it leads to different processing patterns than mutable data.

Click on the titles to expand them.

<details>
<summary><h3>Updating a value in a map</h3></summary>

Let's assume you have a piece of data like this:

```elixir
data = %{"id" => "ABCDEF"}
```

And you need to lower case the id value (`"ABCDEF"`), with all other fields remaining the same. The expected result is:

```elixir
iex> downcase_id.(data)
%{"id" => "abcdef"}
```

Solutions:

You can achieve it by using the `|` (map specific update) operator:

```elixir
downcase_id = fn %{"id" => id} = data ->
  %{data | "id" => String.downcase(id)}
end
```

or [`Map.update!/3`](https://hexdocs.pm/elixir/Map.html#update!/3)

```elixir
downcase_id = fn data ->
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

  # optionally, restructure we may compute a new value based on the
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

This is expensive when the list is big because we may restructure n heads again to generate the new list.
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

We can use `Enum.map/2` (or `Map.new/2` for maps) to update recursively.

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

or

```elixir
def process(map) when is_map(map),
  do: map
      |> Map.new(fn {key, value} ->
        {key, process(value)}
      end)
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

This, of course, is not complete for all projects and you may need to iterate other data structs too. But the point is that you can use this pattern to transform your data’s shape recursively.
</details>

### The refactored code

Let's look back at the code mentioned at the beginning.
The code smells bad because it uses `Map.delete/2` and `Map.put/3` only which are not ideal here. It can be refactored as:

```elixir
def transform_store(store) do
  store
  # Let's separate the update on retailer into another small function.
  |> Map.update!("retailers", &transform_retailer/1)

  # Since replacing key name is so common, it is now a new function.
  |> replace_key_in(~w[id], "_id")

  # We reuse the function to change map key.
  |> replace_key_in(~w[retailers], "retailer")
end

defp transform_retailer(retailer) do
  retailer
  # Here we use `Map.update/4` to update the logo url.
  # The result is slightly different than the original
  # version but should be OK.
  |> Map.update("logoUrl", nil, &(@prefix <> &1))

  # Again, we use `replace_key_in/3` to change key name.
  |> replace_key_in(~w[id], "_id")
  |> replace_key_in(~w[company id], "_id")
end
```

And here's the definition of `replace_key_in/3`:

```elixir
defp replace_key_in(data, [old_name], new_name),
  do: replace_key(data, old_name, new_name)

defp replace_key_in(data, [_ | _] = path, new_name) do
  {path, [old_name]} = Enum.split(path, -1)

  update_in(
    data,
    path,
    &replace_key(&1, old_name, new_name)
  )
end

defp replace_key(data, old_name, new_name) do
  {value, rest} = Map.pop(data, old_name)
  Map.put(rest, new_name, value)
end
```

Let's quickly recap what we have done to improve it.

1. Since replacing a key in a map is so frequent here, we write a helper function `replace_key_in/3` to keep the domain function clear to read. Furthermore, this helper function can be extracted to another place which can be reused by other modules or projects.
2. We use `Kernel.update_in/3` to update the deeply nested map.
3. Several Map APIs (`Map.update!/3`, `Map.pop/2`, and `Map.put/3`) are employed to serve different purposes.

I believe the refactored version is more readable, maintainable, and reusable.

## Conclusion

We have discussed several patterns to update some parts of the data. I hope they are helpful to you!

## Further reading

* [Map module documentation](https://hexdocs.pm/elixir/Map.html)
* [List module documentation](https://hexdocs.pm/elixir/List.html)
