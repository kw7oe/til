defmodule TilWeb.UserControllerTest do
  use TilWeb.ConnCase
  use Plug.Test

  test "requires user authentication on edit", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.user_path(conn, :edit)),
        put(conn, Routes.user_path(conn, :update), user: %{})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "guest" do
    setup %{conn: conn} do
      user = insert(:user)
      post = insert(:post, user: user)
      {:ok, conn: conn, user: user, post: post}
    end

    test "visit specific user profile", %{conn: conn, user: user, post: post} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))

      assert html_response(conn, 200) =~ user.username
      assert html_response(conn, 200) =~ user.bio
      assert html_response(conn, 200) =~ user.website

      assert html_response(conn, 200) =~ post.title
      assert html_response(conn, 200) =~ post.content
    end
  end

  describe "login" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "edit", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit))

      assert html_response(conn, 200) =~ "Profile"
      assert String.contains?(conn.resp_body, user.username)
      assert String.contains?(conn.resp_body, user.email)
    end

    test "update", %{conn: conn} do
      changes = %{username: "new username"}
      update_conn = put(conn, Routes.user_path(conn, :update), user: changes)

      assert redirected_to(update_conn) == Routes.user_path(update_conn, :edit)

      conn = get(conn, Routes.user_path(conn, :edit))
      assert html_response(conn, 200)
    end
  end
end
