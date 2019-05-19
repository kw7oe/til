use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :til, TilWeb.Endpoint,
  # Set to 4001 and true for Integration Test
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :til, Til.Repo,
  username: "postgres",
  password: "postgres",
  database: "til_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Pbkdf2
config :pbkdf2_elixir, :rounds, 1

# Mailer
config :til, Til.Mailer, adapter: Bamboo.LocalAdapter

# Hound
config :hound, driver: "chrome_driver", browser: "chrome"
