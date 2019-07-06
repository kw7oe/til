defmodule Til.PostSearchTest do
  use Til.DataCase

  alias Til.Posts.PostSearch

  setup do
    insert(:post, content: "Hello world")
    insert(:post, content: "This is not my world, world")
    insert(:post, content: "John Wick is cool")

    {:ok, %{}}
  end

  describe "run/2" do
    test "return the result sorted by ranking" do
      result =
        PostSearch.run("world")
        |> Enum.map(fn post -> post.content end)

      assert result == ["This is not my world, world", "Hello world"]
    end

    test "return empty list if posts doesn't exist" do
      result = PostSearch.run("not-exist")
      assert result == []
    end
  end
end
