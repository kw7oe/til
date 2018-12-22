defmodule TilWeb.AccountController do
  use TilWeb, :controller

  alias Til.Accounts
  alias Til.Accounts.Credential
  alias TilWeb.Auth

  plug :authenticate_user when action in [:index]

  def index(conn, _params) do
    accounts = Accounts.list_credentials()
    render(conn, "index.html", accounts: accounts)
  end

  def new(conn, _params) do
    changeset = Accounts.change_credential(%Credential{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"credential" => credential_params}) do
    case Accounts.create_credential(credential_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created")
        |> Auth.login(account)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
