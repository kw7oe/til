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
      user = build(:user) |> set_password("password") |> insert
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "edit", %{conn: conn} do
      conn = get(conn, Routes.password_path(conn, :edit))

      assert html_response(conn, 200) =~ "Change password"
    end

    test "can update password with valid input", %{conn: conn} do
      changes = %{
        "old_password" => "password",
        "new_password" => "newpassword",
        "new_password_confirmation" => "newpassword"
      }

      update_conn = put(conn, Routes.password_path(conn, :update), user: changes)
      assert redirected_to(update_conn) == Routes.password_path(update_conn, :edit)

      conn = get(conn, Routes.password_path(conn, :edit))
      assert html_response(conn, 200) =~ "Change password"
    end

    test "render errors when input is invalid", %{conn: conn} do
      conn = put(conn, Routes.password_path(conn, :update), user: %{})
      assert html_response(conn, 200) =~ "Change password"
      assert html_response(conn, 200) =~ "wrong"
    end
  end
end
