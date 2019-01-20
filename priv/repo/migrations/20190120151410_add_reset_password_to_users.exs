defmodule Til.Repo.Migrations.AddResetPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :reset_password_token, :string
      add :reset_password_at, :naive_datetime
    end
  end
end
