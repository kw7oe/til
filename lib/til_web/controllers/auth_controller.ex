defmodule TilWeb.AuthController do
  use TilWeb, :controller

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(
        %{assigns: %{current_user: %Til.Accounts.User{} = current_user, ueberauth_auth: auth}} =
          conn,
        _params
      ) do
    case UserFromAuth.connect(auth, current_user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Connected to GitHub successfully")
        |> redirect(to: Routes.user_path(conn, :edit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  # def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
  #   case UserFromAuth.find_or_create(auth) do
  #     {:ok, user} ->
  #       conn
  #       |> put_flash(:info, "Successfully authenticated.")
  #       |> put_session(:current_user, user)
  #       |> redirect(to: "/")

  #     {:error, reason} ->
  #       conn
  #       |> put_flash(:error, reason)
  #       |> redirect(to: "/")
  #   end
  # end
end
