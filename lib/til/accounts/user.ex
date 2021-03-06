defmodule Til.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Til.Regexp

  schema "users" do
    field :email, :string
    field :username, :string
    field :avatar_url, :string
    field :github_handle, :string
    field :twitter_handle, :string
    field :bio, :string
    field :website, :string

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
    |> cast(attrs, [
      :email,
      :username,
      :password,
      :avatar_url,
      :twitter_handle,
      :github_handle,
      :bio,
      :website
    ])
    |> validate_required([:email, :username])
    |> validate_length(:username, min: 4, max: 100)
    |> validate_length(:password, min: 6)
    |> validate_format(:website, Regexp.http(), message: Regexp.http_message())
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  def new_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> put_confirmation_token()
  end

  def reset_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6)
    |> put_pass_hash()
    |> clear_reset_token()
  end

  def password_changeset(user, attrs) do
    user
    |> verify_password(attrs)
    |> validate_password_match(attrs)
    |> validate_password_length(attrs)
    |> put_pass_hash()
  end

  defp validate_password_length(changeset, attrs) do
    if attrs["new_password"] && String.length(attrs["new_password"]) < 6 do
      add_error(changeset, :new_password, "should be at least 6 character(s)")
    else
      changeset
    end
  end

  defp validate_password_match(changeset, attrs) do
    if attrs["new_password"] != attrs["new_password_confirmation"] do
      add_error(changeset, :new_password_confirmation, "does not match new password")
    else
      changeset
    end
  end

  defp verify_password(user, attrs) do
    cond do
      attrs["old_password"] && Comeonin.Pbkdf2.checkpw(attrs["old_password"], user.password_hash) ->
        user
        |> cast(%{password: attrs["new_password"]}, [:password])

      attrs["old_password"] == nil ->
        user
        |> change()
        |> add_error(:old_password, "cannot be blank")

      true ->
        user
        |> change()
        |> add_error(:old_password, "must be correct")
    end
  end

  def clear_reset_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: _} ->
        changeset
        |> put_change(:reset_password_token, nil)

      _ ->
        changeset
    end
  end

  def generate_reset_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: _} ->
        changeset
        |> put_change(:reset_password_token, Til.RandomToken.generate())
        |> put_change(
          :reset_password_at,
          NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        )

      _ ->
        changeset
    end
  end

  def put_confirmation_token(changeset) do
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
