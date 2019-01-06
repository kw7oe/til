defmodule Til.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :confirmation_token, :string
    field :confirmed, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :confirmation_token, :confirmed])
    |> validate_required([:name, :confirmation_token, :confirmed])
  end
end
