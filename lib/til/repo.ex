defmodule Til.Repo do
  use Ecto.Repo,
    otp_app: :til,
    adapter: Ecto.Adapters.Postgres
end
