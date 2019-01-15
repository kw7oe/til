defmodule Til.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts.User

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
  Get user by confirmation_token.

  Return `nil` if confirmation token is invalid.
  """
  def check_confirmation_token(token) do
    Repo.get_by(User, confirmation_token: token)
  end

  @doc """
  Authenticate user by email and password
  """
  def authenticate_by_email_and_pass(email, given_pass) do
    query = from c in User, where: c.email == ^email
    user = Repo.one(query)

    cond do
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
    |> User.changeset(attrs)
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
end
