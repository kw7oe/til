defmodule Til.PostIntegrationTest do
  use Til.IntegrationCase
  @moduletag integration: true

  @user_attrs %{username: "kw7oe", password: "password", email: "test@email.com"}
  test "Post Flow" do
    {:ok, user} = Til.Accounts.create_user(@user_attrs)
    {:ok, user} = Til.Accounts.confirm_user(user)

    navigate_to("/")
    login(user)

    # Create Post
    find_element(:link_text, "Add TIL") |> click()
    find_element(:id, "post_title") |> fill_field("TIL: Elixir")
    find_element(:id, "post_virtual_tags") |> fill_field("elixir, phoenix")
    find_element(:id, "post_content") |> fill_field("Elixir is awesome")
    find_element(:id, "post_submit") |> click()

    assert visible_page_text() =~ "successfully"
    assert visible_page_text() =~ "TIL: Elixir"

    # Edit Post
    find_element(:link_text, "Edit") |> click()
    find_element(:id, "post_title") |> fill_field("TIL: Phoenix")
    find_element(:id, "post_submit") |> click()

    assert visible_page_text() =~ "successfully"
    assert visible_page_text() =~ "TIL: Phoenix"

    # Delete Post
    find_element(:link_text, "Delete") |> click()
    accept_dialog()

    assert visible_page_text() =~ "successfully"
    refute visible_page_text() =~ "TIL: Phoenix"
  end

  def login(user) do
    find_element(:link_text, "Login") |> click()
    find_element(:id, "session_email") |> fill_field(user.email)
    find_element(:id, "session_password") |> fill_field(user.password)
    find_element(:class, "btn") |> click()
  end
end
