defmodule TilWeb.ViewHelpers do
  def avatar(%{avatar_url: nil}) do
    Routes.static_path(TilWeb.Endpoint, "/images/default-user.png")
  end

  def avatar(%{avatar_url: ""}) do
    Routes.static_path(TilWeb.Endpoint, "/images/default-user.png")
  end

  def avatar(%{avatar_url: avatar_url}), do: avatar_url
end
