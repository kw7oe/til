defmodule TilWeb.ResetPasswordController do
  use TilWeb, :controller

  alias Til.{Accounts, Mailer}
  alias TilWeb.Email

  # Show email input form to reset password
  # so we can send a link to the user.
  def new(conn, _) do
    render(conn, "new.html")
  end

  # To check user email exist in database and
  # send reset password link to user
  def create(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "Email not found.")
        |> redirect(to: Routes.page_path(conn, :index))

      user ->
        {:ok, user} = Accounts.reset_password(user)
        Email.reset_password_email(user) |> Mailer.deliver_later()

        conn
        |> put_flash(:info, "We have sent a reset password instructions to your email.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  # To check if token is valid
  def edit(conn, %{"token" => token}) do
    case Accounts.check_reset_password_token(token) do
      {:error, _} ->
        conn
        |> put_flash(:error, "Expired/Invalid Token")
        |> redirect(to: Routes.page_path(conn, :index))

      {:ok, user} ->
        changeset = Accounts.change_password(user)

        conn
        |> render("edit.html", user: user, changeset: changeset, token: token)
    end
  end

  # Update user password
  def update(conn, %{"token" => token, "user" => user_params}) do
    with {:ok, user} <- Accounts.check_reset_password_token(token),
         {:ok, _user} <- Accounts.update_password(user, user_params) do
      conn
      |> put_flash(:info, "Password updated successfully.")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
