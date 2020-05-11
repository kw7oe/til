import Config

config :til, TilWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT")],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :til, Til.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: 15

# Update provider configuration
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.fetch_env!("GITHUB_CLIENT_ID"),
  client_secret: System.fetch_env!("GITHUB_CLIENT_SECRET")

# Mailer
config :til, Til.Mailer,
  api_key: System.fetch_env!("MAILGUN_API_KEY"),
  domain: System.fetch_env!("MAILGUN_DOMAIN")
