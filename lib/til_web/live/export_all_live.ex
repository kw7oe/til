defmodule TilWeb.ExportAllLive do
  use Phoenix.LiveView

  alias Til.Posts
  alias TilWeb.PostView

  def mount(session, socket) do
    {:ok,
     assign(socket,
       user_id: session.user_id,
       exporting: false,
       percentage: 0,
       show_download: false
     )}
  end

  def render(assigns), do: PostView.render("export_all_live.html", assigns)

  def handle_event("export", _, socket) do
    send(self(), :start_export)
    {:noreply, assign(socket, exporting: true, percentage: 0)}
  end

  def handle_info({:tick, val}, socket) do
    {:noreply, assign(socket, percentage: val)}
  end

  def handle_info(:start_export, socket) do
    user_id = socket.assigns.user_id

    send(self(), {:tick, 10})
    send(self(), {:fetch_from_db, user_id})

    {:noreply, socket}
  end

  def handle_info({:fetch_from_db, user_id}, socket) do
    posts = Posts.list_user_posts(user_id)
    percentage = 20
    posts_length = length(posts)
    increment = (98 - percentage) / posts_length

    send(self(), {:tick, percentage})
    send(self(), {:converting, posts, [], percentage, increment})

    {:noreply, socket}
  end

  def handle_info({:converting, [h | tail], result, percentage, increment}, socket) do
    new_percentage = percentage + increment
    post = convert_to_binary(h)

    send(self(), {:tick, new_percentage})
    send(self(), {:converting, tail, [post | result], new_percentage, increment})

    {:noreply, socket}
  end

  def handle_info({:converting, [], result, _, _}, socket) do
    user_id = socket.assigns.user_id
    filename = get_filename(user_id, "tar.gz")

    :erl_tar.create("#{filename}", result, [:gz])

    send(self(), {:tick, 100})
    Process.send_after(self(), :show_download, 500)

    {:noreply, socket}
  end

  def handle_info(:show_download, socket) do
    {:noreply, assign(socket, show_download: true)}
  end

  defp convert_to_binary(post) do
    {to_charlist(get_filename(post.title, "md")), post.content}
  end

  defp get_filename(title, extension) do
    "#{title}.#{extension}"
    |> String.downcase()
    |> String.replace(" ", "-")
    |> Zarex.sanitize()
  end
end
