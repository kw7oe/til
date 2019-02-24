defmodule Til.Posts.PostTag do
  use Ecto.Schema

  schema "posts_tags" do
    belongs_to :post, Til.Posts.Post
    belongs_to :tag, Til.Posts.Tag
  end
end
