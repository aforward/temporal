defmodule Temporal.DownloaderTest do

  use ExUnit.Case
  doctest Temporal.Downloader
  alias Temporal.Downloader

  @url "https://raw.githubusercontent.com/aforward/webfiles/master/x.txt"
  @local "/tmp/raw.githubusercontent.com/aforward/webfiles/master/x.txt"

  test "clear" do
    Downloader.clear()
    assert [] == Downloader.files
    Downloader.now(%{source: @url, frequency: :once, force: true})
    assert [@local] == Downloader.files()
  end

  test "now" do
    assert @local == Downloader.now(%{source: @url, frequency: :once})
  end

  test "later" do
    Downloader.clear()
    assert :ok == Downloader.later(%{source: @url, frequency: :once, force: true})
    :timer.sleep(1000)
    assert [@local] == Downloader.files()
  end

end
