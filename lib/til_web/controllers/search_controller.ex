defmodule TilWeb.SearchController do
  use TilWeb, :controller

  alias Til.Posts.PostSearch
  alias Til.Repo

  def create(conn, %{"query" => query}) do
    posts =
      PostSearch.run(query)
      |> Repo.preload(:user)

    render(conn, "show.html", posts: posts)
  end
end
