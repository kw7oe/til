defmodule TilWeb.AuthControllerTest do
  use TilWeb.ConnCase
  use Plug.Test

  describe "github auth" do
    test "successful auth on login user", %{conn: conn} do
      user = insert(:user)

      auth = %Ueberauth.Auth{
        provider: :github,
        info: %{nickname: "kw7oe"}
      }

      conn
      |> bypass_through(TilWeb.Router, :browser)
      |> assign(:current_user, user)
      |> assign(:ueberauth_auth, auth)
      # We must issue a request against the router to prevent
      # error such as flash not fetched.
      |> get("/")
      |> TilWeb.AuthController.callback(%{})

      reload_user = Til.Repo.get!(Til.Accounts.User, user.id)
      assert reload_user.github_handle == "kw7oe"
    end

    test "failure auth on login user", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> assign(:current_user, user)
        |> assign(:ueberauth_failure, %{})
        |> get("/auth/github/callback")

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end
end
