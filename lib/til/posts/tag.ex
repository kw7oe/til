defmodule Til.Posts.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "tags" do
    field :name, :string

    many_to_many :posts, Til.Posts.Post, join_through: Til.Posts.PostTag

    timestamps()
  end

  def with_posts(query \\ __MODULE__, id) do
    from(q in query, where: q.id == ^id, preload: [posts: [:tags, :user]])
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
