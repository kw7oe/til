defmodule TilWeb.Email do
  use Bamboo.Phoenix, view: TilWeb.EmailView

  def welcome_email(user) do
    base_email()
    |> to(user)
    |> subject("Welcome to TIL")
    |> assign(:user, user)
    |> render("sign_in.html")
  end

  defp base_email do
    new_email()
    |> from("choongkwern@hotmail.com")
    |> put_header("Reply-To", "choongkwern@hotmail.com")
    |> put_html_layout({TilWeb.LayoutView, "email.html"})
  end
end

defimpl Bamboo.Formatter, for: Til.Accounts.User do
  def format_email_address(user, _opts) do
    {user.username, user.email}
  end
end
