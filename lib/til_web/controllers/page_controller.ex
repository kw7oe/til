defmodule TilWeb.PageController do
  use TilWeb, :controller

  alias Til.Posts

  def index(conn, params) do
    tags = Map.get(params, "tags", "")
           |> String.split(",", trim: true)

    posts = Posts.list_posts(tags)
    render(conn, "index.html", posts: posts)
  end
end
