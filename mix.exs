defmodule Til.MixProject do
  use Mix.Project

  def project do
    [
      app: :til,
      version: "0.3.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Til.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.6"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # Date/Time Library
      {:timex, "~> 3.1"},

      # Pagination
      {:scrivener_ecto, "~> 2.0"},
      {:scrivener_html, "~> 1.8"},

      # Authentication Dependencies
      {:comeonin, "~> 4.1"},
      {:pbkdf2_elixir, "~> 0.12"},

      # Markdown
      {:earmark, "~> 1.3.1"},

      # Email
      {:bamboo, "~> 1.1"},

      # OAuth Github
      {:ueberauth_github, "~> 0.7"},
      # Deps of oauth2 in ueberauth_github
      {:poison, "~> 3.1"},

      # File Sanitization
      {:zarex, "~> 1.0"},

      # Phoenix Live View
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},

      # Testing
      {:ex_machina, "~> 2.2"},
      {:excoveralls, "~> 0.10", only: :test},
      {:hound, "~> 1.1", only: :test},

      # Deployment
      {:distillery, "~> 2.0"},
      {:honeybadger, "~> 0.7"},

      # Metrics
      {:prometheus_ex, "~> 3.0"},
      {:prometheus_plugs, "~> 1.1.1"},
      {:prometheus_ecto, "~> 1.4.1"},
      {:prometheus_phoenix, "~> 1.2.0"},
      {:prometheus_process_collector, "~> 1.4.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
