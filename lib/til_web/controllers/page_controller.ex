defmodule TilWeb.PageController do
  use TilWeb, :controller

  alias Til.Posts

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def test(conn, _params) do
    Til.Email.welcome_email() |> Til.Mailer.deliver_later()
    text(conn, "OKAY")
  end
end
