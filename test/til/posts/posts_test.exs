defmodule Til.PostsTest do
  use Til.DataCase

  # alias Til.Posts.Tag
  alias Til.Posts
  alias Til.Posts.Post

  describe "count_for/1" do
    test "return the right count" do
      user = insert(:user)
      _post = insert(:post, user: user)
      _post = insert(:post, user: user)
      _post = insert(:post)

      result = Posts.count_for(user.id)
      assert 2 = result
    end
  end

  describe "list_user_posts/1" do
    setup do
      user = insert(:confirmed_user)
      _other_user_post = insert(:post, title: "Post")
      _user_post1 = insert(:post, title: "Post 1", user: user)
      _user_post2 = insert(:post, title: "Post 2", user: user)
      {:ok, %{user: user}}
    end

    test "should return all user posts", %{user: user} do
      result =
        Posts.list_user_posts(user)
        |> Enum.map(& &1.title)
        |> Enum.sort()

      assert result == ["Post 1", "Post 2"]
    end
  end

  describe "filter_by_tags" do
    setup do
      user = insert(:confirmed_user)
      tag = insert(:tag, name: "ruby")
      tag2 = insert(:tag, name: "elixir")
      _post_without_tag = insert(:post, title: "Post no tag", user: user)
      _post = insert(:post, title: "Post", user: user, tags: [tag2])
      _post2 = insert(:post, title: "Post 2", user: user, tags: [tag])
      _post3 = insert(:post, title: "Post 3", user: user, tags: [tag])
      _post4 = insert(:post, title: "Post 4", user: user, tags: [tag, tag2])
      {:ok, %{}}
    end

    test "should return all posts if tags is empty" do
      result = Post.filter_by_tags([]) |> Repo.all() |> Enum.map(& &1.title) |> Enum.sort()
      assert result == ["Post", "Post 2", "Post 3", "Post 4", "Post no tag"]
    end

    test "should return a list of posts associated with the tags" do
      result = Post.filter_by_tags(["ruby"]) |> Repo.all() |> Enum.map(& &1.title) |> Enum.sort()
      assert result == ["Post 2", "Post 3", "Post 4"]
    end

    test "should return a list of posts that only containes tag1 or tag2 without duplicate" do
      result =
        Post.filter_by_tags(["ruby", "elixir"])
        |> Repo.all()
        |> Enum.map(& &1.title)
        |> Enum.sort()

      assert result == ["Post", "Post 2", "Post 3", "Post 4"]
    end

    test "should return empty records if no posts found" do
      result = Post.filter_by_tags(["apple"]) |> Repo.all() |> Enum.map(& &1.title)
      assert result == []
    end
  end

  describe "tags" do
    test "list_posts_by_tag should return all the posts associated by the tag" do
    end
  end
end
