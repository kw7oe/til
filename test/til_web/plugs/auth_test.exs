defmodule TilWeb.AuthTest do
  use TilWeb.ConnCase
  use Plug.Test

  alias TilWeb.Auth

  describe "call/2" do
    setup do
      user = insert(:user)
      {:ok, user: user}
    end

    test "assign user to current_user if user_id exist in session", %{user: user} do
      conn =
        build_conn()
        |> init_test_session(%{user_id: user.id})
        |> fetch_session()
        |> Auth.call(%{})

      assert get_session(conn, :user_id) == user.id
      assert conn.assigns[:current_user].email == user.email
    end

    test "assign user to current_user if remember_token from cookies is valid", %{user: user} do
      conn =
        build_conn()
        |> init_test_session(%{})
        |> fetch_session()
        |> Auth.remember_me(user.id)
        |> fetch_cookies()
        |> Auth.call(%{})

      assert get_session(conn, :user_id) == user.id
      assert conn.assigns[:current_user].email == user.email
    end

    test "assign nil to current_user if remember_token does not contain existing user id" do
      conn =
        build_conn()
        |> init_test_session(%{})
        |> fetch_session()
        |> put_resp_cookie("remember_token", "lalala", max_age: 86_400)
        |> fetch_cookies()
        |> Auth.call(%{})

      assert Map.has_key?(conn.assigns, :current_user)
      assert conn.assigns[:current_user] == nil
    end

    test "assign nil to current_user if user_id does not exist" do
      conn = build_conn() |> init_test_session(%{}) |> fetch_session() |> Auth.call(%{})
      assert Map.has_key?(conn.assigns, :current_user)
      assert conn.assigns[:current_user] == nil
    end
  end

  describe "remember_me/2" do
    setup do
      user = insert(:user)
      conn = build_conn() |> Auth.remember_me(user.id) |> fetch_cookies()
      {:ok, user: user, conn: conn}
    end

    test "adds cookies with token", %{conn: conn} do
      assert Map.get(conn.cookies, "remember_token") != nil
    end
  end

  describe "verify_remember_token/2" do
    setup do
      user = insert(:user)
      conn = build_conn() |> Auth.remember_me(user.id) |> fetch_cookies()
      {:ok, user: user, conn: conn}
    end

    test "return :ok and user id if token is valid", %{user: user, conn: conn} do
      token = Map.get(conn.cookies, "remember_token")
      assert user.id == Auth.verify_remember_token(token)
    end

    test "return :error if token is invalid" do
      assert nil == Auth.verify_remember_token("invalid token")
    end
  end
end
