defmodule Til.Tasks.UpdatePostDocumentsTask do
  @moduledoc """
  To transform the content "posts" table title
  and content into `tsvector` for full text search.
  """

  alias Til.Repo
  alias Til.Posts.Post
  import Ecto.Query

  def run do
    exists_post_ids_query =
      from pd in "post_documents",
        select: pd.post_id

    post_ids = Repo.all(exists_post_ids_query)

    query =
      from p in Post,
        where: not (p.id in ^post_ids),
        select: [:id, :title, :content]

    data =
      query
      |> Repo.all()
      |> Enum.map(fn post ->
        "(DEFAULT, to_tsvector($$#{post.title}$$) || ' ' || to_tsvector($$#{post.content}$$), #{
          post.id
        })"
      end)
      |> Enum.join(", ")

    Repo.query("INSERT INTO post_documents (id, document, post_id) VALUES #{data}")
  end
end
