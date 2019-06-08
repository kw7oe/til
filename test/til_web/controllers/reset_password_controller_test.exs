defmodule TilWeb.RestPasswordControllerTest do
  use TilWeb.ConnCase
  use Plug.Test
  use Bamboo.Test

  alias Til.Accounts

  describe "new" do
    test "render reset password page", %{conn: conn} do
      conn = get(conn, Routes.reset_password_path(conn, :new))
      assert html_response(conn, 200) =~ "Reset Your Password"
    end
  end

  describe "create" do
    test "action trigger password reset when email exist", %{conn: conn} do
      user = insert(:user)

      conn = post(conn, Routes.reset_password_path(conn, :create), email: user.email)
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      updated_user = Accounts.get_user!(user.id)
      assert_delivered_email(TilWeb.Email.reset_password_email(updated_user))
      conn = get(conn, Routes.page_path(conn, :index))

      assert html_response(conn, 200) =~
               "We have sent a reset password instructions to your email"
    end

    test "render errors when email is not found", %{conn: conn} do
      conn = post(conn, Routes.reset_password_path(conn, :create), email: "email@missing.com")
      assert redirected_to(conn) == Routes.reset_password_path(conn, :new)

      conn = get(conn, Routes.reset_password_path(conn, :new))
      assert html_response(conn, 200) =~ "Email not found"
    end
  end

  describe "edit" do
    test "render edit password page if token is valid", %{conn: conn} do
      {:ok, user} = insert(:user) |> Accounts.reset_password()
      conn = get(conn, Routes.reset_password_path(conn, :edit, user.reset_password_token))

      assert html_response(conn, 200) =~ "Change Your Password"
    end

    test "render error if token is invalid", %{conn: conn} do
      conn = get(conn, Routes.reset_password_path(conn, :edit, "invalid token"))
      assert redirected_to(conn) == Routes.reset_password_path(conn, :new)

      conn = get(conn, Routes.reset_password_path(conn, :new))
      assert html_response(conn, 200) =~ "Expired/Invalid Token"
    end
  end

  describe "update" do
    setup %{conn: conn} do
      {:ok, user} = insert(:user) |> Accounts.reset_password()

      {:ok, conn: conn, user: user}
    end

    test "update password when input is valid", %{conn: conn, user: user} do
      params = %{password: "newpassword", password_confirmation: "newpassword"}

      conn =
        put(conn, Routes.reset_password_path(conn, :update, user.reset_password_token),
          user: params
        )

      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "updated"
    end

    test "render error when token is expired/invalid", %{conn: conn} do
      params = %{password: "newpassword", password_confirmation: "newpassword"}
      conn = put(conn, Routes.reset_password_path(conn, :update, "invalid token"), user: params)

      assert redirected_to(conn) == Routes.reset_password_path(conn, :new)

      conn = get(conn, Routes.reset_password_path(conn, :new))
      assert html_response(conn, 200) =~ "Expired/Invalid Token"
    end

    test "render error when input is invalid", %{conn: conn, user: user} do
      params = %{password: "newpassword", password_confirmation: "notmatch"}

      conn =
        put(conn, Routes.reset_password_path(conn, :update, user.reset_password_token),
          user: params
        )

      assert html_response(conn, 200) =~ "wrong"
    end
  end
end
