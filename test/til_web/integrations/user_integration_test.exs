defmodule Til.UserIntegrationTest do
  use Til.IntegrationCase
  @moduletag integration: true

  def click_more do
    find_element(:id, "more_dropdown") |> click()
  end

  def fill_in_user_info(%{username: username, email: email, password: password}) do
    find_element(:id, "user_username") |> fill_field(username)
    find_element(:id, "user_email") |> fill_field(email)
    find_element(:id, "user_password") |> fill_field(password)
    find_element(:class, "btn") |> click()
  end

  def fill_in_sign_in_info(%{email: email, password: password}) do
    find_element(:id, "session_email") |> fill_field(email)
    find_element(:id, "session_password") |> fill_field(password)
    find_element(:class, "btn") |> click()
  end

  setup do
    # When using Chrome Headless, it has the window size of a mobile devices.
    #
    # We resize the window to carry out UI testing in a desktop
    # breakpoint so some elements will be present without the need of toggling
    # additional element.
    set_window_size(current_window_handle(), 1280, 720)

    :ok
  end

  test "User Flow" do
    user = %{username: "kw7oe", password: "password", email: "kw7oe@email.com"}

    # Sign Up
    navigate_to(Routes.page_path(@endpoint, :index))
    find_element(:link_text, "Register") |> click()
    fill_in_user_info(user)
    assert visible_page_text() =~ "Check your inbox"

    db_user = Til.Accounts.get_user_by_email(user.email)

    # Validate User Email
    navigate_to(Routes.confirmation_path(@endpoint, :new, db_user.confirmation_token))
    assert visible_page_text() =~ "verified"

    # Logout
    click_more()
    find_element(:id, "logout_link") |> click()
    assert visible_page_text() =~ "Logout successfully."
    assert visible_page_text() =~ "Login"

    # Login
    find_element(:link_text, "Login") |> click()
    fill_in_sign_in_info(user)
    assert visible_page_text() =~ "Welcome"

    # Edit and Update Profile
    click_more()
    find_element(:link_text, "Edit Profile") |> click()
    find_element(:id, "user_username") |> fill_field("new_name")
    find_element(:class, "btn") |> click()
    assert visible_page_text() =~ "successfully"
  end
end
