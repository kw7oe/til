defmodule Til.PostExporter do
  alias Til.{Posts, Accounts}

  @doc """
  Export a single post into a tuple of filename and binary.

  Return {filename, {:binary, content}}
  """
  def export_to_markdown(%Posts.Post{} = post) do
    filename = get_filename(post.title, "md")
    content = {:binary, format_content(post)}

    {filename, content}
  end

  @doc """
  Export all of the given user posts in to Markdown file and create
  a tar file.

  Return {:ok, file path of the tarfile} on success, :error on failure.
  """
  def compressed_posts_to_tar_from(%Accounts.User{} = user) do
    filename = get_filename(user.username, "tar.gz")

    posts =
      user
      |> Posts.list_user_posts()
      |> Enum.map(&convert_to_binary/1)

    case create_tar(filename, posts) do
      :ok -> {:ok, filename}
      :error -> :error
    end
  end

  @doc """
  Create a tarfile.

  Return :ok on success, :error on failure.
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

  Raise RuntimeError if input is invalid.
  """
  def convert_to_binary(%Til.Posts.Post{} = post) do
    {
      to_charlist(get_filename(post.title, "md")),
      format_content(post)
    }
  end

  def convert_to_binary(_), do: raise("Invalid input; title and content key is expected")

  @doc """
  Format post into Markdown file content.
  """
  def format_content(post) do
    """
    ---
    title: #{post.title}
    tags: #{TilWeb.PostView.tag_list(post.tags)}
    date: #{post.inserted_at}
    ---

    #{post.content}
    """
  end

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
