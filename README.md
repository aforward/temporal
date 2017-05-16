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

## Configuration

You can configure the following defaults.

```elixir
config :temporal,
  basedir: "/tmp",
  frequency: :daily,
  method: :get,
  force: false
```

The default values are shown above, so only if you don't trust they
will remain that way, or if you want something different should
you add the configuration to your application.
are shown below

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

If you want to schedule the download, say every hour, then call

```elixir
Temporal.schedule_now(
  %{basedir: "/tmp",
    frequency: :hourly,
    source: "https://example.com/myfile.txt",
    method: :get})
```

If you want to schedule the download, say every hour, but you do not
need to wait for the actual down, then change the call to `schedule_later`

```elixir
Temporal.schedule_later(
  %{basedir: "/tmp",
    frequency: :hourly,
    source: "https://example.com/myfile.txt",
    method: :get})
```

Finally, if you want to me notified when a new file has been downloaded, then
you can register callback functions

```elixir
Temporal.Callback.register(
  fn(params, fname) ->
    IO.puts("NEW FILE DOWNLOADED")
    IO.inspect(params)
    IO.puts("called #{fname}")
  end)
```

