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
  pubsub_server: Til.PubSub,
  live_view: [
    signing_salt: "sLAWzAz7qDbmjBinjMcHr1TD621kn/TI"
  ]

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

# Mailer
config :til, Til.Mailer, adapter: Bamboo.MailgunAdapter

# Pagination
config :scrivener_html,
  routes_helper: TilWeb.Router.Helpers,
  # If you use a single view style everywhere, you can configure it here. See View Styles below for more info.
  view_style: :bootstrap_v4

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
