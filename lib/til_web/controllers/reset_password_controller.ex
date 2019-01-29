defmodule TilWeb.ResetPasswordController do
  use TilWeb, :controller

  alias Til.Accounts
  alias TilWeb.Auth

  # def new(conn, _) do
  # TODO: Show email input form to reset password
  #       so we can send a link to the user.
  # end
  #
  # def create(conn, %{"user" => user_params}) do
  # TODO: To check user email exist in database and
  #       send reset password link to user
  # end

  # To check if token is valid
  # TODO: Change to edit()
  def new(conn, %{"token" => token}) do
    case Accounts.check_reset_password_token(token) do
      {:error, _} ->
        conn
        |> put_flash(:error, "Expired/Invalid Token")
        |> redirect(to: Routes.page_path(conn, :index))

      user ->
        changeset = Accounts.change_user(user)

        conn
        |> render("new.html", user: user, changeset: changeset)
    end
  end

  # TODO: Update user password
  #       Change to update()
  def create(conn, %{"user" => user_params}) do
    conn
  end
end
