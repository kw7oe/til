defmodule Til.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :confirmation_token, :string
      add :confirmed, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, :username)
  end
end
