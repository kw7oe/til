defmodule Til.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Til.Repo
  alias Til.Accounts
  alias Til.Posts.Post

  def list_credential_posts(%Accounts.Credential{} = credential) do
    Post
    |> credential_posts_query(credential)
    |> Repo.all()
    |> preload_credential()
  end

  def get_credential_post!(%Accounts.Credential{} = credential, id) do
    from(p in Post, where: p.id == ^id)
    |> credential_posts_query(credential)
    |> Repo.one!()
    |> preload_credential()
  end

  def list_posts do
    Repo.all(Post)
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> preload_credential()
  end

  def create_post(%Accounts.Credential{} = credential, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> put_credential(credential)
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

  def change_post(%Accounts.Credential{} = credential, %Post{} = post) do
    post
    |> Post.changeset(%{})
    |> put_credential(credential)
  end

  defp put_credential(changeset, credential) do
    Ecto.Changeset.put_assoc(changeset, :credential, credential)
  end

  defp credential_posts_query(query, %Accounts.Credential{id: credential_id}) do
    from(p in query, where: p.credential_id == ^credential_id)
  end

  defp preload_credential(post_or_posts) do
    Repo.preload(post_or_posts, :credential)
  end
end
