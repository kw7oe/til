defmodule TilWeb.PageController do
  use TilWeb, :controller

  alias Til.Posts

  def index(conn, params) do
    tags =
      Map.get(params, "tags", "")
      |> String.split(",", trim: true)

    all_tags = Posts.list_tags() |> Enum.map(& &1.name)

    page = Posts.list_posts_with_paginate(tags, params)

    render(conn, "index.html",
      posts: page.entries,
      page: Map.delete(page, :entries),
      tags: all_tags
    )
  end

  def about(conn, _) do
    render(conn, "about.html")
  end
end
