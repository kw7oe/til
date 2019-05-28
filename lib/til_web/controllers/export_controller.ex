defmodule TilWeb.ExportController do
  use TilWeb, :controller

  alias Til.Posts

  def export(conn, %{"id" => post_id}) do
    post = Posts.get_post!(post_id)
    filepath = "#{post.title}.md"
    File.write!(filepath, post.content)

    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filepath}"))
    |> send_file(200, filepath)
  end
end
