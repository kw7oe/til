defmodule TilWeb.ExportControllerTest do
  use TilWeb.ConnCase
  use TilWeb.TestHelper
  use Plug.Test

  describe "export" do
    setup %{conn: conn} do
      user = insert(:user)
      {:ok, conn: login(conn, user), user: user}
    end

    test "send Markdown file if post exist", %{conn: conn, user: user} do
      post = insert(:post, user: user)

      conn = get(conn, Routes.export_path(conn, :export, post.id))

      assert conn.state == :file
      assert conn.resp_body =~ post.content

      [content_disposition_value | _] = get_resp_header(conn, "content-disposition")
      assert content_disposition_value =~ "#{post.title}.md"
    end
  end
end
