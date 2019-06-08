defmodule Til.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts.User

  # 15 minutes * 60 seconds = 900 seconds
  @valid_reset_password_token_second 900

  @doc """
  Generate remember token for user
  """
  def remember_me(user) do
    attrs = %{remember_token: Til.RandomToken.generate()}

    user
    |> Ecto.Changeset.change(attrs)
    |> Repo.update()
  end

  @doc """
  Get User by email

  Return 'nil' if does not exist.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Update `confirmed` column of user to true
  """
  def confirm_user(user) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:confirmed, true)
    |> Repo.update()
  end

  @doc """
  Update `confirmed` column of user to false
  """
  def unconfirm_user(user) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:confirmed, false)
    |> Repo.update()
  end

  @doc """
  Generate 'reset_password_token` and `reset_password_at`
  value for user.
  """
  def reset_password(user) do
    user
    |> Ecto.Changeset.change()
    |> User.generate_reset_password()
    |> Repo.update()
  end

  @doc """
  Generate confirmation token for user.
  """
  def add_confirmation_token(user) do
    user
    |> Ecto.Changeset.change()
    |> User.put_confirmation_token()
    |> Repo.update()
  end

  @doc """
  Update password for user. Require old password to be correct and
  new password to match confirmation.
  """
  def update_password(%User{} = user, :change, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update password for user. Action from reset password.
  """
  def update_password(%User{} = user, :reset, attrs) do
    user
    |> User.reset_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Get user by confirmation_token.

  Return `nil` if confirmation token is invalid.
  """
  def check_confirmation_token(token) do
    Repo.get_by(User, confirmation_token: token)
  end

  @doc """
  Check if reset password token is valid or invalid.

  If the current time is 15 minutes more than the reset_password_at
  time, it is considered as expired.

  A expired token is considered as invalid token.
  """
  def check_reset_password_token(token) do
    user = Repo.get_by(User, reset_password_token: token)

    cond do
      user &&
          NaiveDateTime.diff(NaiveDateTime.utc_now(), user.reset_password_at) <
            @valid_reset_password_token_second ->
        {:ok, user}

      user ->
        {:error, :expired}

      true ->
        {:error, :invalid}
    end
  end

  @doc """
  Authenticate user by email and password
  """
  def authenticate_by_email_and_pass(email, given_pass) do
    query = from c in User, where: c.email == ^email
    user = Repo.one(query)

    cond do
      user && !user.confirmed ->
        {:error, :unconfirm}

      user && Comeonin.Pbkdf2.checkpw(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Pbkdf2.dummy_checkpw()
        {:error, :not_found}
    end
  end

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.new_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset()` for change password only
  """
  def change_password(%User{} = user) do
    User.password_changeset(user, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset()` for reset password only
  """
  def change_reset_password(%User{} = user) do
    User.reset_password_changeset(user, %{})
  end
end
