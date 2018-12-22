defmodule Til.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :text
      add :credential_id, references(:credentials, on_delete: :nothing)

      timestamps()
    end

    create index(:posts, [:credential_id])
  end
end
