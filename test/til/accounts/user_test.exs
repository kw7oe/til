defmodule Til.UserTest do
  use Til.DataCase
  alias Til.Accounts.User

  import Ecto.Changeset

  @valid_attrs %{email: "test@example.com", username: "test", password: "password"}

  test "generate_reset_password should generate reset_password_token and reset_password_at" do
    result = %User{}
             |> User.changeset(@valid_attrs)
             |> User.generate_reset_password()
             |> apply_changes()

    assert result.reset_password_token != nil
    assert result.reset_password_at != nil
  end
end
