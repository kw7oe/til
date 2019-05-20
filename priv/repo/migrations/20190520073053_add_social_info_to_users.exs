defmodule Til.Repo.Migrations.AddSocialInfoToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:github_handle, :string)
      add(:twitter_handle, :string)
      add(:bio, :string)
      add(:website, :string)
    end
  end
end
