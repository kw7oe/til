defmodule TilWeb.ConfirmationController do
  use TilWeb, :controller

  alias Til.Accounts
  alias TilWeb.Auth

  def new(conn, %{"token" => token}) do
    case Accounts.check_confirmation_token(token) do
      nil ->
        conn
        |> put_flash(:error, "Expired/Invalid Confirmation Token")
        |> redirect(to: Routes.page_path(conn, :index))

      user ->
        Accounts.confirm_user(user)

        conn
        |> put_flash(:info, "Your email has been verified. Welcome to TIL")
        |> Auth.login(user)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
