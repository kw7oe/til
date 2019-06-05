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
      assert %{website: [^message]} = errors_on(changeset)
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
    assert result.password_hash != nil
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

  describe "password_changeset/1" do
    setup do
      user = %User{} |> User.changeset(@valid_attrs) |> apply_changes()

      changes = %{
        "old_password" => "password",
        "new_password" => "newpassword",
        "new_password_confirmation" => "newpassword"
      }

      {:ok, user: user, changes: changes}
    end

    test "apple changes if old password is correct", %{user: user, changes: changes} do
      old_password_hash = user.password_hash

      changeset = user |> User.password_changeset(changes)
      assert changeset.valid?

      updated_user = changeset |> apply_changes()
      assert old_password_hash != updated_user.password_hash
    end

    test "return error message if new password doesn't match confirmation", %{
      user: user,
      changes: changes
    } do
      invalid_changes = Map.put(changes, "new_password", "newpasswordnotmatch")
      changeset = user |> User.password_changeset(invalid_changes)

      refute changeset.valid?

      assert %{new_password_confirmation: ["does not match new password"]} = errors_on(changeset)
    end

    test "return error message if new password is too short", %{user: user, changes: changes} do
      invalid_changes =
        Map.merge(changes, %{"new_password" => "short", "new_password_confirmation" => "short"})

      changeset = user |> User.password_changeset(invalid_changes)

      refute changeset.valid?

      assert %{new_password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end

    test "return error message if old password is incorrect", %{user: user, changes: changes} do
      invalid_changes = Map.put(changes, "old_password", "wrong password")
      changeset = user |> User.password_changeset(invalid_changes)

      refute changeset.valid?
      assert %{old_password: ["must be correct"]} = errors_on(changeset)
    end
  end
end
