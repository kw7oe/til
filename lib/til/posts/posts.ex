defmodule Til.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts
  alias Til.Posts.Post

  def list_user_posts(%Accounts.User{} = user) do
    Post
    |> user_posts_query(user)
    |> Repo.all()
    |> preload_user()
  end

  def get_user_post!(%Accounts.User{} = user, id) do
    from(p in Post, where: p.id == ^id)
    |> user_posts_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  def list_posts do
    Repo.all(Post)
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> preload_user()
  end

  def create_post(%Accounts.User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Accounts.User{} = user, %Post{} = post) do
    post
    |> Post.changeset(%{})
    |> put_user(user)
  end

  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  defp user_posts_query(query, %Accounts.User{id: user_id}) do
    from(p in query, where: p.user_id == ^user_id)
  end

  defp preload_user(post_or_posts) do
    Repo.preload(post_or_posts, :user)
  end

  alias Til.Posts.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end
end
