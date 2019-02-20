defmodule Til.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts
  alias Til.Posts.{Post, Tag}

  def list_user_posts(%Accounts.User{} = user) do
    Post.submitted_by(user.id)
    |> Post.ordered()
    |> Repo.all()
    |> preload_user()
    |> preload_tags()
  end

  def get_user_post!(%Accounts.User{} = user, id) do
    from(p in Post, where: p.id == ^id)
    |> Post.submitted_by(user.id)
    |> Repo.one!()
    |> preload_user()
    |> preload_tags()
  end

  def list_posts(tags) do
    Post.ordered()
    |> Post.filter_by_tags(tags)
    |> Repo.all()
    |> preload_user()
    |> preload_tags()
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> preload_user()
    |> preload_tags()
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

  defp preload_user(post_or_posts) do
    Repo.preload(post_or_posts, :user)
  end

  defp preload_tags(post_or_posts) do
    Repo.preload(post_or_posts, :tags)
  end

  @doc """
  Returns the list of tags.
  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Returns a list of posts containing the tag.
  """
  def list_posts_by_tag(tag_id) do
    Tag.with_posts(tag_id)
    |> Repo.one()
  end
end
