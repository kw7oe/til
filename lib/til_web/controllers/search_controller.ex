defmodule TilWeb.SearchController do
  use TilWeb, :controller

  alias Til.Posts.PostSearch

  def create(conn, %{"query" => query}) do
    posts = PostSearch.run(query)
    render(conn, "show.html", posts: posts)
  end
end
