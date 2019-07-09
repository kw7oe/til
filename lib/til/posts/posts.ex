defmodule Til.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts
  alias Til.Posts.{Post, Tag, PostTag}

  def tag_count_for(user_id) do
    user_id
    |> PostTag.involved_by()
    |> Repo.aggregate(:count, :tag_id)
  end

  def count_for(user_id) do
    user_id
    |> Post.submitted_by()
    |> Repo.aggregate(:count, :id)
  end

  def list_user_posts(user_id) when is_integer(user_id) do
    user_id
    |> Post.submitted_by()
    |> preload(:tags)
    |> Repo.all()
  end

  def list_user_posts(%Accounts.User{} = user) do
    user.id
    |> Post.submitted_by()
    |> preload(:tags)
    |> Repo.all()
  end

  def list_user_posts_with_paginate(%Accounts.User{} = user, params) do
    user.id
    |> Post.submitted_by()
    |> Post.ordered()
    |> preload(:user)
    |> preload(:tags)
    |> Repo.paginate(params)
  end

  def list_posts_with_paginate(tags, params) do
    Post.ordered()
    |> Post.filter_by_tags(tags)
    |> preload(:user)
    |> preload(:tags)
    |> Repo.paginate(params)
  end

  def get_user_post!(%Accounts.User{} = user, id) do
    id
    |> Post.by_id()
    |> Post.submitted_by(user.id)
    |> Repo.one!()
    |> preload_user()
    |> preload_tags()
  end

  def get_post!(id) do
    Post
    |> Repo.get!(id)
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
    tag_id
    |> Tag.with_posts()
    |> Repo.one()
  end
end
