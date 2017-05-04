defmodule Temporal.Fetch do

  @doc"""
  Touch a file, useful if you want to "skip" a download

  ## Examples

      iex> Temporal.Fetch.touch(%{basedir: "/tmp/", fequency: :monthly, source: "https://my.a4word.com/webfiles/x.txt"})
      "/tmp/20170504/my.a4word.com/webfiles/x.txt"

      iex> Temporal.Fetch.touch(%{basedir: "/etc/bad", fequency: :monthly, source: "https://my.a4word.com/webfiles/x.txt"})
      "/etc/bad/20170504/my.a4word.com/webfiles/x.txt"

  """
  def touch(%{basedir: basedir, frequency: frequency, source: source}) do
    filename = Temporal.Storage.path(basedir, frequency, source)

    filename
    |> Temporal.Storage.mkdir()
    |> File.touch

    filename
  end
  def touch(args), do: default_opts() |> Map.merge(args) |> touch

  @doc"""
  Clean up a possible fetched file

  ## Examples

      iex> Temporal.Fetch.clean(%{basedir: "/tmp/", fequency: :monthly, source: "https://my.a4word.com/webfiles/x.txt"})
      "/tmp/20170504/my.a4word.com/webfiles/x.txt"

      iex> Temporal.Fetch.clean(%{basedir: "/etc/bad", fequency: :monthly, source: "https://my.a4word.com/webfiles/x.txt"})
      "/etc/bad/20170504/my.a4word.com/webfiles/x.txt"

  """
  def clean(%{basedir: basedir, frequency: frequency, source: source}) do
    filename = Temporal.Storage.path(basedir, frequency, source)
    filename |> File.rm
    filename
  end
  def clean(args), do: default_opts() |> Map.merge(args) |> clean

  @doc"""
  Go and fetch the data if it's time, using the provided method.

      iex> Temporal.Fetch.clean(%{source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      ...> Temporal.Fetch.go(%{source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      {:ok, "/tmp/20170504/raw.githubusercontent.com/aforward/webfiles/master/x.txt"}

      iex> Temporal.Fetch.go(%{method: :get, source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      {:skip, "/tmp/20170504/raw.githubusercontent.com/aforward/webfiles/master/x.txt"}

      iex> Temporal.Fetch.go(%{force: true, method: :get, source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      {:ok, "/tmp/20170504/raw.githubusercontent.com/aforward/webfiles/master/x.txt"}

  """
  def go(%{basedir: basedir,
           frequency: frequency,
           source: source,
           method: _method,
           force: force} = args) do
    cond do
      force -> download(args)
      Temporal.Storage.exists?(basedir, frequency, source) -> {:skip, Temporal.Storage.path(basedir, frequency, source)}
      true -> download(args)
    end
  end
  def go(args), do: default_opts() |> Map.merge(args) |> go

  defp download(%{basedir: basedir,frequency: frequency, source: source, method: method} = args) do
    Temporal.Api.call(method, args)
    |> Temporal.Storage.save(basedir, frequency, source)
  end

  defp default_opts(), do: %{basedir: "/tmp", frequency: :daily, method: :get, force: false}

end