defmodule TilWeb.PostController do
  use TilWeb, :controller

  alias Til.Posts
  alias Til.Posts.Post
  alias Til.Statistic

  plug :authenticate_user when action in [:index, :new, :create, :edit, :update, :delete]

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, params, current_user) do
    page = Posts.list_user_posts_with_paginate(current_user, params)
    total_post_count = Posts.count_for(current_user.id)
    total_tag_count = Posts.tag_count_for(current_user.id)
    writing_streaks = Statistic.writing_streaks(current_user)

    render(conn, "index.html",
      page: Map.delete(page, :entries),
      posts: page.entries,
      total_post_count: total_post_count,
      writing_streaks: writing_streaks,
      total_tag_count: total_tag_count,
      layout: {TilWeb.LayoutView, "dashboard.html"}
    )
  end

  def new(conn, _params, current_user) do
    changeset = Posts.change_post(current_user, %Post{})

    render(conn, "new.html",
      changeset: changeset,
      layout: {TilWeb.LayoutView, "editor_layout.html"}
    )
  end

  def create(conn, %{"post" => post_params}, current_user) do
    case Posts.create_post(current_user, post_params) do
      {:ok, post} ->
        conn = conn |> put_flash(:info, "Post created successfully.")

        if post_params["share_to_twitter"] == "true" do
          url = Routes.post_url(conn, :show, post)
          twitter_intent_url = Til.TwitterIntent.url(post.title, url)
          redirect(conn, to: Routes.post_path(conn, :show, post, twitter_url: twitter_intent_url))
        else
          redirect(conn, to: Routes.post_path(conn, :show, post))
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _current_user) do
    post = Posts.get_post!(id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}, current_user) do
    post = Posts.get_user_post!(current_user, id)
    changeset = Posts.change_post(conn.assigns.current_user, post)

    render(conn, "edit.html",
      post: post,
      changeset: changeset,
      layout: {TilWeb.LayoutView, "editor_layout.html"}
    )
  end

  def update(conn, %{"id" => id, "post" => post_params}, current_user) do
    post = Posts.get_user_post!(current_user, id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          post: post,
          changeset: changeset,
          layout: {TilWeb.LayoutView, "editor_layout.html"}
        )
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    post = Posts.get_user_post!(current_user, id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
end
