defmodule TilWeb.TagController do
  use TilWeb, :controller

  alias Til.Posts

  def index(conn, _) do
    tags = Posts.list_tags()
    render(conn, "index.html", tags: tags)
  end

  def show(conn, %{"id" => id}) do
    tag = Posts.list_posts_by_tag(id)
    render(conn, "show.html", tag: tag)
  end
end
