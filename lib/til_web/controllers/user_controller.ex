defmodule TilWeb.UserController do
  use TilWeb, :controller

  alias Til.Mailer
  alias Til.Accounts
  alias Til.Posts
  alias Til.Accounts.User
  alias TilWeb.Email

  plug :authenticate_user when action in [:index, :edit, :update]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id} = params) do
    user = Accounts.get_user!(id)
    page = Posts.list_user_posts_with_paginate(user, params)
    render(conn, "show.html", page: page, posts: page.entries, user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Email.welcome_email(user) |> Mailer.deliver_later()

        conn
        |> put_flash(:info, "Only one step left! Check your inbox for a confirmation email.")
        # |> Auth.login(user)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Accounts.change_user(conn.assigns.current_user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_user(conn.assigns.current_user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: Routes.user_path(conn, :edit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
