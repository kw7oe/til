defmodule TilWeb.SessionController do
  use TilWeb, :controller

  alias TilWeb.Auth

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{
        "session" => %{"email" => email, "password" => password, "remember_me" => remember_me}
      }) do
    case Auth.login_by_email_and_pass(conn, email, password) do
      {:ok, conn, user_id} ->
        conn = conn |> put_flash(:info, "Welcome back!")

        conn =
          case remember_me do
            "true" -> Auth.remember_me(conn, user_id)
            _ -> conn
          end

        redirect(conn, to: Routes.page_path(conn, :index))

      {:error, :unconfirm, conn} ->
        conn
        |> put_flash(:info, "Hey, you can't login before you confirm your email address.")
        |> render("new.html")

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> put_flash(:info, "Logout successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
