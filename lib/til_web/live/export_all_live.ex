defmodule TilWeb.ExportAllLive do
  use Phoenix.LiveView

  alias Til.Posts
  alias Til.PostExporter
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
    send(self(), {:converting, posts, [], percentage, percentage, increment})

    {:noreply, socket}
  end

  def handle_info(
        {:converting, [h | tail], result, percentage, old_percentage, increment},
        socket
      ) do
    post = PostExporter.convert_to_binary(h)

    new_percentage = percentage + increment
    difference = new_percentage - old_percentage

    old_percentage =
      case difference > 1 do
        true ->
          send(self(), {:tick, new_percentage})
          new_percentage

        false ->
          old_percentage
      end

    send(self(), {:converting, tail, [post | result], new_percentage, old_percentage, increment})

    {:noreply, socket}
  end

  def handle_info({:converting, [], result, _, _, _}, socket) do
    user_id = socket.assigns.user_id
    filename = PostExporter.get_filename(user_id, "tar.gz")
    :ok = PostExporter.create_tar(filename, result)

    send(self(), {:tick, 100})
    Process.send_after(self(), :show_download, 500)

    {:noreply, socket}
  end

  def handle_info(:show_download, socket) do
    {:noreply, assign(socket, show_download: true)}
  end
end
