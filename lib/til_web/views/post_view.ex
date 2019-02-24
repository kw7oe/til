defmodule TilWeb.PostView do
  use TilWeb, :view

  def is_owner(nil, _post), do: false

  def is_owner(current_user, post) do
    current_user.id == post.user_id
  end

  def tag_list(%Ecto.Association.NotLoaded{}), do: ""

  def tag_list(tags) do
    tags |> Enum.map(fn t -> t.name() end) |> Enum.join(", ")
  end
end
