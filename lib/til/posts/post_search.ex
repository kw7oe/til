defmodule Til.Posts.PostSearch do
  @moduledoc """
  To carry out full text search for posts.
  """

  use Ecto.Schema
  import Ecto.Query
  alias Til.Repo

  alias Til.Posts.Post

  def run(search_string) do
    post_documents_query = post_documents_by(search_string)

    post_query =
      from p in Post,
        join: pd in subquery(post_documents_query),
        on: p.id == pd.post_id,
        order_by: [desc: pd.rank]

    Repo.all(post_query)
  end

  def post_documents_by(search_string) do
    from q in "post_documents",
      where: fragment("document @@ plainto_tsquery(?)", ^search_string),
      select: %{
        post_id: fragment("post_id"),
        rank: fragment("ts_rank(document, plainto_tsquery(?))", ^search_string)
      }
  end
end
