defmodule Til.Posts.PostTag do
  use Ecto.Schema

  import Ecto.Query
  alias Til.Posts.Post

  schema "posts_tags" do
    belongs_to :post, Til.Posts.Post
    belongs_to :tag, Til.Posts.Tag
  end

  def involved_by(query \\ __MODULE__, user_id) do
    from q in query,
      join: p in Post,
      on: q.post_id == p.id,
      where: p.user_id == ^user_id,
      distinct: true,
      select: [:tag_id]
  end
end
