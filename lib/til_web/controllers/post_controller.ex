defmodule TilWeb.PostController do
  use TilWeb, :controller

  alias Til.Posts
  alias Til.Posts.Post

  @twitter_intent "https://twitter.com/intent/tweet"

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    posts = Posts.list_user_posts(current_user)
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params, current_user) do
    changeset = Posts.change_post(current_user, %Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}, current_user) do
    case Posts.create_post(current_user, post_params) do
      {:ok, post} ->
        conn = conn |> put_flash(:info, "Post created successfully.")

        if post_params["share_to_twitter"] == "true" do
          # REFACTOR: Extract out the composition logic of Twitter URL intent
          #           to a seperate module
          #
          # Eexmaple:
          #           url = Routes.post_url(conn, :show, post)
          #           twitter_intent = TwitterIntent.url(post.title, url)
          redirect(conn, external: "#{@twitter_intent}?text=TIL: #{post.title}&url=#{Routes.post_url(conn, :show, post)}")
        else
          redirect(conn, to: Routes.post_path(conn, :show, post))
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    post = Posts.get_user_post!(current_user, id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}, current_user) do
    post = Posts.get_user_post!(current_user, id)
    changeset = Posts.change_post(conn.assigns.current_user, post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}, current_user) do
    post = Posts.get_user_post!(current_user, id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
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
