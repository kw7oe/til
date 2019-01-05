defmodule Til.Email do
  use Bamboo.Phoenix, view: TilWeb.EmailView

  def welcome_email do
    base_email()
    |> to("choongkwern@hotmail.com")
    |> subject("Welcome")
    |> put_header("Reply-To", "choongkwern@hotmail.com")
    |> render("sign_in.html")
  end

  defp base_email do
    new_email()
    |> from("choongkwern@hotmail.com")
    |> put_html_layout({TilWeb.LayoutView, "email.html"})
  end
end
