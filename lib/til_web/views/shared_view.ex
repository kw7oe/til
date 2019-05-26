defmodule TilWeb.SharedView do
  use TilWeb, :view
  import Scrivener.HTML

  def current_path?(conn, path) do
    current_path = Path.join(["/" | conn.path_info])
    current_path == path
  end

  def active_link_to(conn, title, to: path, class: class, active_class: active_class) do
    class_name =
      cond do
        current_path?(conn, path) -> "#{class} #{active_class}"
        true -> class
      end

    link(title, to: path, class: class_name)
  end
end
