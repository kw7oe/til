defmodule TilWeb.ConfirmationController do
  use TilWeb, :controller

  def new(conn, _params) do
    conn
    |> put_flash(:info, "Your email has been verified. You can log in now.")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
