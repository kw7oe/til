defmodule TilWeb.SearchView do
  use TilWeb, :view

  def post_excerpt(content) do
    content_length = String.length(content)

    if content_length < 100 do
      content
    else
      String.slice(content, 0, 100) <> "..."
    end
  end
end
