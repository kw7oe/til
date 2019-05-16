defmodule TilWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias Til.Accounts
  alias TilWeb.Router.Helpers, as: Routes

  # In seconds, 15 days. One day has 86400 seconds.
  @remember_token_age 86400 * 15

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      conn.assigns[:current_user] ->
        conn

      true ->
        {conn, user_id} =
          case Map.get(conn.cookies, "remember_token") do
            nil ->
              {conn, get_session(conn, :user_id)}

            token ->
              result = verify_remember_token(token)

              conn =
                conn
                |> put_session(:user_id, result)
                |> configure_session(renew: true)

              {conn, result}
          end

        user = user_id && Accounts.get_user!(user_id)
        assign(conn, :current_user, user)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # Important to protect us from session fixation attacks
    |> configure_session(renew: true)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} -> {:ok, login(conn, user), user.id}
      {:error, reason} -> {:error, reason, conn}
    end
  end

  def logout(conn) do
    conn
    |> delete_resp_cookie("remember_token")
    # Use clear_session instead of configure_session(:drop)
    # to allow flash messsage to be sent to client
    |> clear_session()
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  @doc """
  To generate Phoniex.Token for remember token and add it to request cookies
  encoded with the User id.
  """
  def remember_me(conn, user_id) do
    token = Phoenix.Token.sign(TilWeb.Endpoint, "remember salt", user_id)

    conn
    |> put_resp_cookie("remember_token", token, max_age: @remember_token_age)
  end

  @doc """
  To verify remember token from cookies.

  If valid, it will return user_id
  If invalid, it will return nil
  """
  def verify_remember_token(token) do
    case Phoenix.Token.verify(TilWeb.Endpoint, "remember salt", token,
           max_age: @remember_token_age
         ) do
      {:ok, user_id} -> user_id
      {:error, _} -> nil
    end
  end
end
