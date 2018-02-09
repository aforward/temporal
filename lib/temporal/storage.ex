defmodule Temporal.Storage do
  @moduledoc """
  Save and retrieve downloaded data from third party APIs
  """

  @doc """
  Save the data that was fetched from the interwebs.
  You can either provide the path directly, or use the
  combination of `basedir`, `frequency` and `source` to
  have it calculated.

  ## Examples

      iex> Temporal.Storage.save({:ok, "apples"}, "/tmp/abc/apples.txt")
      {:ok, "/tmp/abc/apples.txt"}

      iex> Temporal.Storage.save({:error, "Broken"}, "/tmp/abc/apples.txt")
      {:error, "Broken"}

  """
  def save(response, basedir, frequency, source) do
    save(response, path(basedir, frequency, source))
  end

  def save({:ok, body}, path) do
    mkdir(path)
    :ok = File.write!(path, body)
    {:ok, path}
  end

  def save(err, _path), do: err

  @doc """
  Ensure the directory is available for saving
  """
  def mkdir(filename) do
    filename |> Path.dirname() |> File.mkdir_p()
    filename
  end

  @doc """
  Retrieve data the data that we saved.
  You can either provide the path directly, or use the
  combination of `basedir`, `frequency` and `source` to
  have it calculated.

  ## Examples

      iex> File.write!("/tmp/apples.txt", "apples") && Temporal.Storage.get("/tmp/apples.txt")
      {:ok, "apples"}

      iex> Temporal.Storage.get("/tmp/bananas.txt")
      {:error, :enoent}

  """
  def get(basedir, frequency, source) do
    path(basedir, frequency, source) |> get
  end

  def get(path) do
    File.read(path)
  end

  @doc """
  Has the data been saved yet?
  You can either provide the path directly, or use the
  combination of `basedir`, `frequency` and `source` to
  have it calculated.

  ## Examples

      iex> File.write!("/tmp/apples.txt", "apples") && Temporal.Storage.exists?("/tmp/apples.txt")
      true

      iex> Temporal.Storage.exists?("/tmp/bananas.txt")
      false

  """
  def exists?(basedir, frequency, source) do
    path(basedir, frequency, source) |> exists?
  end

  def exists?(path) do
    File.exists?(path)
  end

  @doc """
  Calculate a unique path for the source being fetched.  If you
  provide a basedir it will use that as a prefix.

  ## Examples

      iex> Temporal.Storage.path("https://my.a4word.com/webfiles/x.txt")
      "my.a4word.com/webfiles/x.txt"

      iex> Temporal.Storage.path("https://www.dividata.com/stock/MMM")
      "www.dividata.com/stock/mmm"

      iex> Temporal.Storage.path("https://tsx.exdividend.ca/s/?q=T")
      "tsx.exdividend.ca/s/query__q_eq_t"

      iex> Temporal.Storage.path("https://tsx.exdividend.ca/s/lookup?q=T")
      "tsx.exdividend.ca/s/lookup/query__q_eq_t"

      iex> Temporal.Storage.path("http://www.nasdaq.com/symbol/aapl/dividend-history")
      "www.nasdaq.com/symbol/aapl/dividend-history"

      iex> Temporal.Storage.path("http://download.finance.yahoo.com/d/quotes.csv?s=T.TO&f=sod1ax")
      "download.finance.yahoo.com/d/quotes.csv/query__s_eq_t.to_and_f_eq_sod1ax"

      iex> Temporal.Storage.path("/tmp/", :once, "https://my.a4word.com/webfiles/x.txt")
      "/tmp/my.a4word.com/webfiles/x.txt"

      iex> Temporal.Storage.path("/tmp/", "2017", "https://my.a4word.com/webfiles/x.txt")
      "/tmp/2017/my.a4word.com/webfiles/x.txt"

      iex> Temporal.Storage.path("/tmp/abc", "2018", "https://my.a4word.com/webfiles/x.txt")
      "/tmp/abc/2018/my.a4word.com/webfiles/x.txt"

  """
  def path(basedir, frequency, source) when is_atom(frequency) do
    path(basedir, timestamp(frequency), source)
  end

  def path(basedir, ts, source) when is_binary(ts) do
    "#{basedir}/#{ts}/#{path(source)}" |> clean |> clean
  end

  def path(source) do
    %URI{path: path, query: query, fragment: _, host: host, port: _} = URI.parse(source)

    "#{host}#{path}#{query_encode(query)}"
    |> clean
  end

  @doc """
  Determine if it's time to perform your operation.

  ## Examples

    iex> Temporal.Storage.timestamp(~N[2016-05-24 13:26:08.003], :yearly)
    "2016"

    iex> Temporal.Storage.timestamp(~N[2016-05-24 13:26:08.003], :monthly)
    "201605"

    iex> Temporal.Storage.timestamp(~N[2016-05-09 13:26:08.003], :daily)
    "20160509"

    iex> Temporal.Storage.timestamp(~N[2016-05-09 13:26:08.003], :hourly)
    "2016050913"

    iex> Temporal.Storage.timestamp(~N[2016-05-09 13:26:08.003], :once)
    ""

  """
  def timestamp(frequency), do: NaiveDateTime.utc_now() |> timestamp(frequency)
  def timestamp(_date, :once), do: ""
  def timestamp(date, :yearly), do: "#{date.year}"
  def timestamp(date, :monthly), do: "#{timestamp(date, :yearly)}#{pad(date.month, "00")}"
  def timestamp(date, :daily), do: "#{timestamp(date, :monthly)}#{pad(date.day, "00")}"
  def timestamp(date, :hourly), do: "#{timestamp(date, :daily)}#{pad(date.hour, "00")}"

  defp pad(num, zeros) do
    String.pad_leading("#{num}", String.length(zeros), zeros)
  end

  defp query_encode(nil), do: ""

  defp query_encode(q) do
    "/query__#{q}"
    |> String.replace("=", "_eq_")
    |> String.replace("&", "_and_")
  end

  defp clean(path), do: path |> String.downcase() |> String.replace("//", "/")
end
