# Temporal

A library to download documents from the interwebs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `temporal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:temporal, "~> 0.1.1"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and is published at [https://hexdocs.pm/temporal](https://hexdocs.pm/temporal).

## Usage

If you want to download a file then you can run

```elixir
Temporal.download_now(
  %{basedir: "/tmp",
    frequency: :once,
    source: "https://example.com/myfile.txt",
    method: :get})
```

This will only download the file if you haven't already, if you wanted to force a new download then add `force: true`, for example

```elixir
Temporal.download_now(
  %{basedir: "/tmp",
    frequency: :once,
    force: true,
    source: "https://example.com/myfile.txt",
    method: :get})
```
