defmodule Til.Accounts.User do
  use Ecto.Schema
  use Timex
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :username, :string

    field :password, :string, virtual: true
    field :password_hash, :string

    field :confirmation_token, :string
    field :confirmed, :boolean, default: false

    field :reset_password_token, :string
    field :reset_password_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> validate_length(:username, min: 4, max: 100)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash()
    |> put_confirmation_token()
  end

  def generate_reset_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: _} ->
        changeset
        |> put_change(:reset_password_token, Til.RandomToken.generate())
        |> put_change(:reset_password_at, NaiveDateTime.utc_now |> NaiveDateTime.truncate(:second))
      _ ->
        changeset
    end
  end

  defp put_confirmation_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: _} ->
        put_change(changeset, :confirmation_token, Til.RandomToken.generate())

      _ ->
        changeset
    end
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
