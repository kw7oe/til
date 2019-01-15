defmodule Til.AccountsTest do
  use Til.DataCase
  alias Til.Accounts

  @valid_attrs %{email: "test@example.com", username: "test", password: "password"}
  @invalid_attrs %{email: "test@example.com", username: "123", password: "123"}

  describe "users" do
    test "create_user/1 with valid create user and generate confirmation token" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert user.email == "test@example.com"
      assert user.username == "test"
      assert user.confirmation_token != nil
    end

    test "create_user/1 with invalid return error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "confirm_user/1 return result.confirmed as true" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      {:ok, result} = Accounts.confirm_user(user)
      assert result.confirmed
    end
  end
end
