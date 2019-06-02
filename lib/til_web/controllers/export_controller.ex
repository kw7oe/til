defmodule TilWeb.ExportController do
  use TilWeb, :controller

  alias Til.Posts
  alias Til.PostExporter

  plug :authenticate_user

  def download(conn, %{"tarfile" => tarname}) do
    current_user_id = conn.assigns.current_user.id

    [tar_id, _, _] = String.split(tarname, ".")

    case Integer.parse(tar_id) do
      {^current_user_id, _} ->
        conn
        |> put_resp_header("content-disposition", ~s(attachment; filename="#{tarname}"))
        |> send_file(200, tarname)

      _ ->
        conn
        |> put_flash(:error, "Access denied.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def export_all(conn, _params) do
    filename = PostExporter.compressed_posts_to_tar_from(conn.assigns.current_user)

    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_file(200, filename)
  end

  def export(conn, %{"id" => post_id}) do
    post = Posts.get_post!(post_id)
    {filename, content} = PostExporter.export_to_markdown(post)

    conn
    |> send_download(content, filename: filename)
  end
end
