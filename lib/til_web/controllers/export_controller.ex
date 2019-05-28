defmodule TilWeb.ExportController do
  use TilWeb, :controller

  alias Til.Posts

  def export(conn, %{"id" => post_id}) do
    post = Posts.get_post!(post_id)

    # TODO: Extract to a method instead
    filename =
      "#{post.title}.md"
      |> String.downcase()
      |> String.replace(" ", "-")
      |> Zarex.sanitize()

    conn
    |> send_download({:binary, post.content}, filename: filename)
  end
end
