defmodule TilWeb.ResendConfirmationController do
  use TilWeb, :controller

  alias Til.Accounts
  alias TilWeb.Email
  alias Til.Mailer

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        :ok

      user ->
        if user.confirmation_token == nil do
          Accounts.add_confirmation_token(user)
        end

        Email.welcome_email(user) |> Mailer.deliver_later()
    end

    conn
    |> put_flash(:info, "We have resend your confirmation link to your email.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
