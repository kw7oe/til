defmodule TilWeb.ExportControllerTest do
  use TilWeb.ConnCase
  use TilWeb.TestHelper
  use Plug.Test

  test "require user login", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.export_path(conn, :export, 1)),
        get(conn, Routes.export_path(conn, :export_all)),
        get(conn, Routes.export_path(conn, :download, "test.tar.gz"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "login user" do
    setup %{conn: conn} do
      user = insert(:user)
      {:ok, conn: login(conn, user), user: user}
    end

    test "can download tar files given the correct filename", %{conn: conn, user: user} do
      filename = "#{user.id}.tar.gz"
      File.write!(filename, "test tarfile")

      conn = get(conn, Routes.export_path(conn, :download, filename))

      assert conn.state == :file
    end

    test "redirect with error message if user are not authorized", %{conn: conn, user: user} do
      filename = "#{user.id + 1}.tar.gz"
      conn = get(conn, Routes.export_path(conn, :download, filename))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Access denied"
    end

    test "redirect with error message if filename doesn't exist", %{conn: conn} do
      filename = "doesnexsit.tar.gz"
      conn = get(conn, Routes.export_path(conn, :download, filename))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Access denied"
    end

    test "can get tar files when export all", %{conn: conn} do
      conn = get(conn, Routes.export_path(conn, :export_all))

      assert conn.state == :file
      [content_disposition_value | _] = get_resp_header(conn, "content-disposition")
      assert content_disposition_value =~ ".tar.gz"
    end

    test "can get Markdown file if a specific post exist", %{conn: conn, user: user} do
      post = insert(:post, user: user)
      conn = get(conn, Routes.export_path(conn, :export, post.id))

      assert conn.resp_body =~ post.content

      [content_disposition_value | _] = get_resp_header(conn, "content-disposition")
      assert content_disposition_value =~ "#{post.title}.md"
    end
  end
end
