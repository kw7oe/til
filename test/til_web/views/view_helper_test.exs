defmodule TilWeb.ViewHelperTest do
  use TilWeb.ConnCase, async: true

  alias TilWeb.ViewHelpers
  alias TilWeb.Router.Helpers, as: Routes

  describe "avatar" do
    test "return default image if avatar url is not available" do
      default_image = Routes.static_path(TilWeb.Endpoint, "/images/default-user.png")

      assert default_image == ViewHelpers.avatar(%{avatar_url: ""})
      assert default_image == ViewHelpers.avatar(%{avatar_url: nil})
    end

    test "return avatar url" do
      avatar_url = "https://www.example.com/image.png"
      assert avatar_url == ViewHelpers.avatar(%{avatar_url: avatar_url})
    end
  end
end
