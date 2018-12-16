defmodule Til.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset


  schema "credentials" do
    field :email, :string
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password_hash])
    |> validate_required([:email, :password_hash])
    |> unique_constraint(:email)
  end
end
