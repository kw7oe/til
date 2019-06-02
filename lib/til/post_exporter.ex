defmodule Til.PostExporter do
  alias Til.{Posts, Accounts}

  @doc """
  Export a single post into a tuple of filename and binary.

  Return {filename, {:binary, content}}
  """
  def export_to_markdown(post = %Posts.Post{}) do
    filename = get_filename(post.title, "md")
    content = {:binary, post.content}

    {filename, content}
  end

  @doc """
  Export all of the given user posts in to Markdown file and create
  a tar file.

  Return file path of the tarfile.
  """
  def compressed_posts_to_tar_from(user = %Accounts.User{}) do
    filename = get_filename(user.username, "tar.gz")

    posts =
      Posts.list_user_posts(user)
      |> Enum.map(&convert_to_binary/1)

    case create_tar(filename, posts) do
      :ok -> {:ok, filename}
      :error -> :error
    end
  end

  @doc """
  Create a tarfile.
  """
  def create_tar(filename, posts) do
    try do
      :erl_tar.create("#{filename}", posts, [:gz])
    rescue
      _ ->
        :error
    end
  end

  @doc """
  Convert post into binary format expected from erl_tar, which is
  {'filename', binary}.
  """
  def convert_to_binary(%{title: title, content: content}) do
    {to_charlist(get_filename(title, "md")), content}
  end

  def convert_to_binary(_), do: raise("Invalid input; title and content key is expected")

  @doc """
  Sanitize and format filename given the title and extension
  """
  def get_filename(title, extension) do
    "#{title}.#{extension}"
    |> String.downcase()
    |> String.replace(" ", "-")
    |> Zarex.sanitize()
  end
end
