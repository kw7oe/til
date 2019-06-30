# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :til,
  ecto_repos: [Til.Repo]

# Configures the endpoint
config :til, TilWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aEr0QHunp0TboxnM1Iuk14J67l51PJGvchp7hUuXsnyu/aS0FII90LeFWqF0wYKS",
  render_errors: [view: TilWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Til.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "sLAWzAz7qDbmjBinjMcHr1TD621kn/TI"
  ],
  instrumenters: [Til.PhoenixInstrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Add GitHub to Ueberauth Config
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email", allow_private_emails: true]}
  ]

# Update provider configuration
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Mailer
config :til, Til.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")

# Pagination
config :scrivener_html,
  routes_helper: TilWeb.Router.Helpers,
  # If you use a single view style everywhere, you can configure it here. See View Styles below for more info.
  view_style: :bootstrap_v4

# Prometheus
config :prometheus, Til.PhoenixInstrumenter,
  controller_call_labels: [:controller, :action],
  duration_buckets: [
    10,
    25,
    50,
    100,
    250,
    500,
    1000,
    2500,
    5000,
    10_000,
    25_000,
    50_000,
    100_000,
    250_000,
    500_000,
    1_000_000,
    2_500_000,
    5_000_000,
    10_000_000
  ],
  registry: :default,
  duration_unit: :microseconds

config :prometheus, Til.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [
    10,
    100,
    1_000,
    10_000,
    100_000,
    300_000,
    500_000,
    750_000,
    1_000_000,
    1_500_000,
    2_000_000,
    3_000_000
  ],
  registry: :default,
  duration_unit: :microseconds

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
