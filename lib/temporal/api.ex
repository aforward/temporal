defmodule Temporal.Api do
  @moduledoc """
  Download files from the interweb
  """

  @doc """
  Retrieve data from the interwebs using either :get or :post

  ## Examples

      iex> Temporal.Api.call(:get, %{source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      {:ok, "A text file\\n"}

      iex> Temporal.Api.call(:post, %{source: "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"})
      {:error, "Expected a 200, received 400"}
  """
  def call(:get, %{source: source, headers: headers}), do: get(source, headers)
  def call(:get, %{source: source}), do: get(source)

  def call(:post, %{source: source, body: body, headers: headers}),
    do: post(source, body, headers)

  def call(:post, %{source: source, body: body}), do: post(source, body)
  def call(:post, %{source: source}), do: post(source)

  @doc """
  Download a particular file using GET.  Optionally provide any required headers

  ## Examples

      iex> Temporal.Api.get("https://raw.githubusercontent.com/aforward/webfiles/master/x.txt")
      {:ok, "A text file\\n"}

      iex> Temporal.Api.get("https://raw.githubusercontent.com/aforward/webfiles/master/x.txt", %{content_type: "text/html"})
      {:ok, "A text file\\n"}

      iex> Temporal.Api.get("https://raw.githubusercontent.com/aforward/webfiles/master/missing.txt")
      {:error, "Expected a 200, received 404"}

      iex> Temporal.Api.get("http://localhost:1")
      {:error, :econnrefused}

  """
  def get(source), do: get(source, nil)

  def get(source, headers) do
    source
    |> HTTPoison.get(encode_headers(headers))
    |> parse
  end

  @doc """
  Download a particular file using POST.  Optionally provide any required data and headers

  Sorry, the examples suck and only show the :error case.

  ## Examples

      iex> Temporal.Api.post("https://raw.githubusercontent.com/aforward/webfiles/master/x.txt")
      {:error, "Expected a 200, received 400"}

      iex> Temporal.Api.post("https://raw.githubusercontent.com/aforward/webfiles/master/x.txt", %{a: "b"})
      {:error, "Expected a 200, received 400"}

      iex> Temporal.Api.post("https://raw.githubusercontent.com/aforward/webfiles/master/x.txt", %{}, %{body_type: "application/json"})
      {:error, "Expected a 200, received 400"}

      iex> Temporal.Api.post("http://localhost:1")
      {:error, :econnrefused}

  """
  def post(source), do: post(source, %{}, %{})
  def post(source, body), do: post(source, body, %{})

  def post(source, body, headers) do
    source
    |> HTTPoison.post(
      encode_body(headers[:body_type] || headers[:content_type], body),
      encode_headers(headers)
    )
    |> parse
  end

  @doc """
  Encode the provided hash map for the URL.

  ## Examples

      iex> Temporal.Api.encode_body(%{a: "one", b: "two"})
      "a=one&b=two"

      iex> Temporal.Api.encode_body(%{a: "o ne"})
      "a=o+ne"

      iex> Temporal.Api.encode_body(nil, %{a: "o ne"})
      "a=o+ne"

      iex> Temporal.Api.encode_body("application/x-www-form-urlencoded", %{a: "o ne"})
      "a=o+ne"

      iex> Temporal.Api.encode_body("application/json", %{a: "b"})
      "{\\"a\\":\\"b\\"}"

  """
  def encode_body(map), do: encode_body(nil, map)
  def encode_body(nil, map), do: encode_body("application/x-www-form-urlencoded", map)
  def encode_body("application/x-www-form-urlencoded", map), do: URI.encode_query(map)
  def encode_body("application/json", map), do: Jason.encode!(map)
  def encode_body(_, map), do: encode_body(nil, map)

  @doc """
  Build the headers for your API

  ## Examples

      iex> Temporal.Api.encode_headers(%{content_type: "application/json", bearer: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/json"}]

      iex> Temporal.Api.encode_headers(%{bearer: "abc123"})
      [{"Authorization", "Bearer abc123"}]

      iex> Temporal.Api.encode_headers(%{})
      []

      iex> Temporal.Api.encode_headers()
      []

      iex> Temporal.Api.encode_headers(nil)
      []

  """
  def encode_headers(), do: encode_headers(%{})
  def encode_headers(nil), do: encode_headers(%{})

  def encode_headers(data) do
    data
    |> reject_nil
    |> Enum.map(&header/1)
    |> Enum.reject(&is_nil/1)
  end

  defp header({:bearer, bearer}), do: {"Authorization", "Bearer #{bearer}"}
  defp header({:content_type, content_type}), do: {"Content-Type", content_type}
  defp header({:body_type, _}), do: nil

  defp parse({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    {:ok, body}
  end

  defp parse({:ok, %HTTPoison.Response{status_code: code}}) do
    {:error, "Expected a 200, received #{code}"}
  end

  defp parse({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  defp reject_nil(map) do
    map
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end
end
