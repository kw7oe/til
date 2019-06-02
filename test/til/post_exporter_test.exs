defmodule Til.PostExporterTest do
  use ExUnit.Case, async: true

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
      assert_raise RuntimeError, "fail to create tar", fn ->
        PostExporter.create_tar("test.tar.gz", nil)
      end
    end
  end

  describe "convert_to_binary" do
    test "should convert post to expected format" do
      post = %{title: "post", content: "hello TIL"}

      result = PostExporter.convert_to_binary(post)
      assert {'post.md', "hello TIL"} = result
    end

    test "should raise error if invalid input" do
      assert_raise RuntimeError, fn ->
        PostExporter.convert_to_binary(nil)
      end
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
