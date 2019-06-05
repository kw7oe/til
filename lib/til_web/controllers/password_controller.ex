defmodule TilWeb.PasswordController do
  use TilWeb, :controller

  alias Til.Accounts

  plug :authenticate_user

  def edit(conn, _) do
    changeset = Accounts.change_user(conn.assigns.current_user)
    render(conn, "edit.html", changeset: changeset, layout: {TilWeb.LayoutView, "dashboard.html"})
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_password(conn.assigns.current_user, :change, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(
          to: Routes.password_path(conn, :edit),
          layout: {TilWeb.LayoutView, "dashboard.html"}
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          changeset: changeset,
          layout: {TilWeb.LayoutView, "dashboard.html"}
        )
    end
  end
end
