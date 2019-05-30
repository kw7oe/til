defmodule TilWeb.ExportController do
  use TilWeb, :controller

  alias Til.Posts

  def export_all(conn, _params) do
    current_user = conn.assigns.current_user
    tar_filename = get_filename(current_user.username, "tar.gz")

    posts =
      Posts.list_user_posts(current_user)
      |> Enum.map(&convert_to_binary/1)

    :erl_tar.create("#{tar_filename}", posts, [:gz])

    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{tar_filename}"))
    |> send_file(200, tar_filename)
  end

  def export(conn, %{"id" => post_id}) do
    post = Posts.get_post!(post_id)
    filename = get_filename(post.title, "md")

    conn
    |> send_download({:binary, post.content}, filename: filename)
  end

  defp convert_to_binary(post) do
    {to_charlist(get_filename(post.title, "md")), post.content}
  end

  defp get_filename(title, extension) do
    "#{title}.#{extension}"
    |> String.downcase()
    |> String.replace(" ", "-")
    |> Zarex.sanitize()
  end
end
