# RulEx

> A simple to use, simple to extend rules engine, written in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rul_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rul_ex, "~> 1.0.0"},
    # In order to use the default encoding, if you don't wish to use Jason
    # you can use any module you want that implements the same APIs as
    # Jason and configure the application environment [:rul_ex, RulEx.Encoding.Json]
    # configuration.
    {:jason, "~> 1.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rul_ex](https://hexdocs.pm/rul_ex).

> Note to anyone wanting to use this:
>
> If I would've needed this in a real life example I would probabl use it, however,
> this is not battle-tested, and was conceived just as means to have a fun side
> thing to do that didn't consume too much time/effort from me.
