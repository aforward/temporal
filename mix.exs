defmodule Temporal.Mixfile do
  use Mix.Project

  @name :temporal
  @friendly_name "Temporal"
  @description "A library to download documents from the interwebs."
  @version "0.3.0"
  @git_url "https://github.com/aforward/temporal"
  @home_url @git_url

  @deps [
    {:mix_test_watch, github: "aforward/mix-test.watch", only: :dev, runtime: false},
    {:httpoison, "~> 1.0"},
    {:jason, "~> 1.0"},
    {:ex_doc, ">= 0.0.0", only: :dev},
    {:version_tasks, "~> 0.11.1"},
  ]

  @aliases []

  @package [
    name: @name,
    files: ["lib", "mix.exs", "README*", "LICENSE*"],
    maintainers: ["Andrew Forward"],
    licenses: ["MIT"],
    links: %{"GitHub" => @git_url}
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      name: @friendly_name,
      description: @description,
      elixir: ">= 1.6.0",
      deps: @deps,
      aliases: @aliases,
      package: @package,
      source_url: @git_url,
      homepage_url: @home_url,
      build_embedded: in_production,
      start_permanent: in_production
    ]
  end

  def application do
    [
      mod: {Temporal.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end
end
