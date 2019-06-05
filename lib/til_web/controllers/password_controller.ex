defmodule TilWeb.PasswordController do
  use TilWeb, :controller

  alias Til.Accounts

  plug :authenticate_user

  def edit(conn, _) do
    changeset = Accounts.change_password(conn.assigns.current_user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, _) do
    conn
  end
end
