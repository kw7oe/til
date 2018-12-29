defmodule TilWeb.PostChannel do
  use TilWeb, :channel

  def join("post", _params, socket) do
    {:ok, socket}
  end

  def handle_in("update", params, socket) do
    broadcast!(socket, "preview", %{
      preview: Earmark.as_html! params
    })
    {:reply, :ok, socket}
  end
end
