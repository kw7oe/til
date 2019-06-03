defmodule Til.PostExporterTest do
  use Til.DataCase
  alias Til.PostExporter

  describe "create_tar" do
    test "should create tar file with right input" do
      filename = "test.tar.gz"

      result =
        PostExporter.create_tar(
          filename,
          [{'filename.md', "content"}]
        )

      assert :ok = result
      assert File.exists?(filename)
    end

    test "should raise error if creation failed" do
      result = PostExporter.create_tar("test.tar.gz", nil)
      assert :error = result
    end
  end

  describe "convert_to_binary" do
    test "should convert post to expected format" do
      post = insert(:post, title: "post")

      {title, content} = PostExporter.convert_to_binary(post)
      assert 'post.md' = title
      assert content =~ post.content
    end

    test "should raise error if invalid input" do
      assert_raise RuntimeError, fn ->
        PostExporter.convert_to_binary(nil)
      end
    end
  end

  describe "format_content" do
    test "should include title, tags, date and content" do
      user = insert(:user)

      {:ok, post} =
        Til.Posts.create_post(user, %{
          "title" => "Post Title",
          "content" => "Hello World",
          "virtual_tags" => "test, tag"
        })

      result = PostExporter.format_content(post)

      assert result =~ "title: #{post.title}"
      assert result =~ "tags: test, tag"
      assert result =~ "date: #{post.inserted_at}"
      assert result =~ post.content
    end
  end

  describe "get_filename" do
    test "should sanitize filename" do
      result = PostExporter.get_filename("/test/\\", "md")

      assert result == "test.md"
    end

    test "should remove excessive whitespace" do
      result = PostExporter.get_filename("test hello", "md")

      assert result == "test-hello.md"
    end

    test "should convert to downcase" do
      result = PostExporter.get_filename("Test", "md")

      assert result == "test.md"
    end
  end
end
