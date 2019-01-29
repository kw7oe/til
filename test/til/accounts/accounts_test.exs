defmodule Til.AccountsTest do
  use Til.DataCase, async: true
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

    test "check_reset_password_token/1 with valid token return user" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      {:ok, user} = Accounts.reset_password(user)

      token = user.reset_password_token
      {:ok, %Accounts.User{}} = Accounts.check_reset_password_token(token)
    end

    test "check_reset_password_token/1 with invalid token return error" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      {:ok, user} = Accounts.reset_password(user)

      token = "invalid token"
      {:error, :invalid} = Accounts.check_reset_password_token(token)
    end
  end
end
