defmodule TilWeb.PostControllerTest do
  use TilWeb.ConnCase
  use TilWeb.TestHelper

  @create_attrs %{content: "some content", title: "some title"}
  @update_attrs %{content: "some updated content", title: "some updated title"}
  @invalid_attrs %{content: nil, title: nil}

  describe "as visitor" do
    test "can visit specific post", %{conn: conn} do
      post = insert(:post)
      conn = get(conn, Routes.post_path(conn, :show, post))
      assert html_response(conn, 200) =~ post.title
    end

    test "cannot visit post related routes other than show", %{conn: conn} do
      routes = [
        get(conn, Routes.post_path(conn, :index)),
        get(conn, Routes.post_path(conn, :new)),
        post(conn, Routes.post_path(conn, :create), post: @create_attrs),
        get(conn, Routes.post_path(conn, :edit, "1")),
        delete(conn, Routes.post_path(conn, :delete, "1"))
      ]

      routes
      |> Enum.each(fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
    end
  end

  describe "as login user" do
    setup %{conn: conn} do
      user = insert(:user)
      {:ok, conn: login(conn, user), user: user}
    end

    test "can only see all posts he/she posted", %{conn: conn, user: user} do
      user_post = insert(:post, user: user)
      other_post = insert(:post)
      conn = get(conn, Routes.post_path(conn, :index))

      assert html_response(conn, 200) =~ "Posts"
      assert html_response(conn, 200) =~ user_post.title
      refute html_response(conn, 200) =~ other_post.title
    end

    test "can add TIL post", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :new))
      assert html_response(conn, 200) =~ "Submit"
    end

    test "can create post with valid attrs", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.post_path(conn, :show, id)

      conn = get(conn, Routes.post_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some title"
    end

    test "can create post and share to twitter", %{conn: conn} do
      params = Map.merge(@create_attrs, %{"share_to_twitter" => "true"})
      conn = post(conn, Routes.post_path(conn, :create), post: params)

      assert %{id: id} = redirected_params(conn)

      post_url = Routes.post_url(conn, :show, id)
      twitter_url = Til.TwitterIntent.url(@create_attrs.title, post_url)
      assert redirected_to(conn) == Routes.post_path(conn, :show, id, twitter_url: twitter_url)

      conn = get(conn, post_url)
      assert html_response(conn, 200) =~ "some title"
    end

    test "cannot create posts with invalid attributes", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Submit"
    end

    test "can edit chosen post", %{conn: conn, user: user} do
      post = insert(:post, user: user)
      conn = get(conn, Routes.post_path(conn, :edit, post))
      assert html_response(conn, 200) =~ "Submit"
    end

    test "redirects when data is valid", %{conn: conn, user: user} do
      post = insert(:post, user: user)
      conn = put(conn, Routes.post_path(conn, :update, post), post: @update_attrs)
      assert redirected_to(conn) == Routes.post_path(conn, :show, post)

      conn = get(conn, Routes.post_path(conn, :show, post))
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      post = insert(:post, user: user)
      conn = put(conn, Routes.post_path(conn, :update, post), post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Submit"
    end

    test "can deletes chosen post", %{conn: conn, user: user} do
      post = insert(:post, user: user)
      conn = delete(conn, Routes.post_path(conn, :delete, post))
      assert redirected_to(conn) == Routes.post_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.post_path(conn, :show, post))
      end
    end
  end
end
