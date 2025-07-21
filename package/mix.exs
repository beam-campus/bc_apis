defmodule BCApis.MixProject do
  @moduledoc false
  use Mix.Project

  @app_name :bc_apis
  @version "0.1.0"
  @elixir_version "~> 1.17"
  @description "BEAM Campus APIs (BCApis) is a collection of freely available APIs for Elixir projects."
  @source_url "https://github.com/beam-campus/bc_apis"
  @docs_url "https://hexdocs.pm/bc_apis"

  def project do
    [
      app: @app_name,
      version: @version,
      elixir: @elixir_version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      releases: releases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: coverage_tool()],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "test.watch": :test,
        credo: :dev,
        dialyzer: :dev
      ]
    ]
  end

  defp releases,
    do: [
      bc_apis: [
        include_erts: true,
        include_executables_for: [:unix],
        steps: [:assemble, :tar],
        applications: [
          runtime_tools: :permanent,
          logger: :permanent
        ]
      ]
    ]

  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support"
    ]

  defp elixirc_paths(_), do: ["lib"]

  defp coverage_tool do
    case System.get_env("CI") do
      "true" -> ExCoveralls
      _ -> {:cover, [output: "_build/cover"]}
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Development tools
      {:dialyze, "~> 0.2.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Testing tools
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:eunit_formatters, "~> 0.5", only: [:test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test], runtime: false},

      # Runtime dependencies - optional
      {:jason, "~> 1.4", optional: true},
      {:phoenix_pubsub, "~> 2.1", optional: true},
      {:req, "~> 0.5"},
      {:hackney, "~> 1.20.1"},
      {:typed_struct, "~> 0.3.0"},
      {:mnemonic_slugs, "~> 0.0.3"},
      {:cachex, "~> 3.6.0"},

      # Runtime dependencies - required
      {:uuidv7, "~> 1.0"},
      {:elixir_uuid, "~> 1.2"},
      {:telemetry, "~> 1.3"},
      {:bc_utils, "~> 0.11.0"}
    ]
  end

  defp docs do
    [
      main: "readme",
      canonical: @docs_url,
      source_ref: "v#{@version}",
      extra_section: "guides",
      extras: [
        "guides/getting_started.md": [
          filename: "getting-started",
          title: "Getting Started"
        ],
        "README.md": [
          filename: "readme",
          title: "Read Me"
        ],
        "CHANGELOG.md": [
          filename: "changelog",
          title: "Changelog"
        ]
      ]
    ]
  end

  defp package do
    [
      name: @app_name,
      description: @description,
      version: @version,
      maintainers: ["rgfaber"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    ]
  end
end
