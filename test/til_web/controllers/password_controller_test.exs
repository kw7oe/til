defmodule TilWeb.PasswordControllerTest do
  use TilWeb.ConnCase
  use Plug.Test

  test "requires user authentication on edit", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.password_path(conn, :edit)),
        put(conn, Routes.password_path(conn, :update), user: %{})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "login" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "edit", %{conn: conn, user: user} do
      conn = get(conn, Routes.password_path(conn, :edit))

      assert html_response(conn, 200) =~ "Change password"
    end

    test "update", %{conn: conn} do
      changes = %{
        old_password: "password",
        new_password: "newpassword",
        new_password_confirmation: "newpassword"
      }

      update_conn = put(conn, Routes.password_path(conn, :update), user: changes)

      assert redirected_to(update_conn) == Routes.password_path(update_conn, :edit)

      conn = get(conn, Routes.password_path(conn, :edit))
      assert html_response(conn, 200)
    end
  end
end
