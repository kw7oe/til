defmodule Til.UserTest do
  use Til.DataCase
  alias Til.Accounts.User
  alias Til.Regexp

  import Ecto.Changeset

  @valid_attrs %{email: "test@example.com", username: "test", password: "password"}

  describe "validate website" do
    test "success with valid url" do
      attrs = Map.merge(@valid_attrs, %{website: "https://www.kaiwern.com"})
      changeset = User.changeset(%User{}, attrs)
      assert changeset.valid?
    end

    test "fail with invalid url" do
      attrs = Map.merge(@valid_attrs, %{website: "www.kaiwern.com"})
      changeset = User.changeset(%User{}, attrs)

      message = Regexp.http_message()
      assert %{website: [message]} = errors_on(changeset)
    end
  end

  test "reset_password_changeset should only change password and reset_password_token" do
    user =
      %User{}
      |> User.changeset(@valid_attrs)
      |> apply_changes()

    old_password_hash = user.password_hash

    result =
      user
      |> User.reset_password_changeset(%{password: "new password", username: "test2"})
      |> apply_changes()

    assert result.reset_password_token == nil
    assert result.username != "test2"
    assert result.password_hash != old_password_hash
  end

  test "generate_reset_password should generate reset_password_token and reset_password_at" do
    result =
      %User{}
      |> User.changeset(@valid_attrs)
      |> User.generate_reset_password()
      |> apply_changes()

    assert result.reset_password_token != nil
    assert result.reset_password_at != nil
  end
end
