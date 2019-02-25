defmodule TilWeb.PageController do
  use TilWeb, :controller

  alias Til.Posts

  def index(conn, params) do
    tags =
      Map.get(params, "tags", "")
      |> String.split(",", trim: true)

    all_tags = Posts.list_tags() |> Enum.map(& &1.name)

    posts = Posts.list_posts(tags)
    render(conn, "index.html", posts: posts, tags: all_tags)
  end

  def about(conn, _) do
    render(conn, "about.html")
  end
end
