defmodule Til.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Til.Repo

  schema "posts" do
    field :content, :string
    field :title, :string
    belongs_to :user, Til.Accounts.User
    many_to_many :tags, Til.Posts.Tag, join_through: Til.Posts.PostTag, on_replace: :delete

    timestamps()
  end

  def ordered(query \\ __MODULE__), do: from(q in query, order_by: [desc: :inserted_at])

  def submitted_by(query \\ __MODULE__, user_id) do
    from(q in query, where: q.user_id == ^user_id)
  end

  def filter_by_date(query \\ __MODULE__, start_date, end_date) do
    from q in query,
      where: q.start_date >= ^start_date,
      where: q.start_date <= ^end_date
  end

  # Method header
  def filter_by_tags(query \\ __MODULE__, tags)
  def filter_by_tags(query, []), do: query

  def filter_by_tags(query, tags) do
    from(
      q in query,
      distinct: true,
      join: pt in Til.Posts.PostTag,
      on: pt.post_id == q.id,
      join: t in Til.Posts.Tag,
      on: pt.tag_id == t.id,
      where: t.name in ^tags
    )
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content])
    |> validate_required([:title, :content])
    |> put_assoc(:tags, parse_tags(attrs))
  end

  def parse_tags(attrs) do
    (attrs["virtual_tags"] || "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> insert_and_get_all_tags()
  end

  def insert_and_get_all_tags([]) do
    []
  end

  def insert_and_get_all_tags(names) do
    time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    maps = Enum.map(names, &%{name: &1, inserted_at: time, updated_at: time})
    Repo.insert_all(Til.Posts.Tag, maps, on_conflict: :nothing)
    Repo.all(from t in Til.Posts.Tag, where: t.name in ^names)
  end
end
