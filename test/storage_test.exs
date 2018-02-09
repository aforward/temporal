defmodule Temporal.StorageTest do
  use ExUnit.Case
  doctest Temporal.Storage

  alias Temporal.Storage

  test "save based on basedir, frequency and source" do
    p = Storage.path("/tmp", :yearly, "https://example.com/x.txt")
    assert {:ok, p} == Storage.save({:ok, "apples"}, "/tmp", :yearly, "https://example.com/x.txt")
    assert true == Storage.exists?("/tmp", :yearly, "https://example.com/x.txt")
    assert true == Storage.exists?(p)
  end

  test "exists? based on basedir, frequency and source" do
    p = Storage.path("/tmp", :yearly, "https://example.com/x.txt")
    assert {:ok, p} == Storage.save({:ok, "apples"}, "/tmp", :yearly, "https://example.com/x.txt")
    assert true == Storage.exists?("/tmp", :yearly, "https://example.com/x.txt")
    assert false == Storage.exists?("/tmp", :monthly, "https://example.com/x.txt")
  end

  test "get based on basedir, frequency and source" do
    p = Storage.path("/tmp", :yearly, "https://example.com/x.txt")
    assert {:ok, p} == Storage.save({:ok, "apples"}, "/tmp", :yearly, "https://example.com/x.txt")
    assert {:ok, "apples"} == Storage.get("/tmp", :yearly, "https://example.com/x.txt")
  end
end
