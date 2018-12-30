defmodule TilWeb.PostView do
  use TilWeb, :view

  def is_owner(nil, post), do: false

  def is_owner(current_user, post) do
    current_user.id == post.credential_id
  end
end
