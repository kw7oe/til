defmodule Til.AccountsTest do
  use Til.DataCase, async: true
  alias Til.Accounts

  @valid_attrs %{email: "test@example.com", username: "test", password: "password"}
  @invalid_attrs %{email: "test@example.com", username: "123", password: "123"}

  test "create_user/1 with invalid return error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  describe "authenticate_by_email_and_pass/2" do
    setup do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      {:ok, user} = Accounts.confirm_user(user)
      {:ok, user: user}
    end

    test "it return ok with user if valid input", context do
      user = context[:user]
      result = Accounts.authenticate_by_email_and_pass(
        "test@example.com", "password"
      )
      assert {:ok, user_from_result} = result
      assert user.email == user_from_result.email
    end

    test "it return error if email is unconfirmed", context do
      user = context[:user]
      Accounts.unconfirm_user(user)
      result = Accounts.authenticate_by_email_and_pass(
        "test@example.com", "password"
      )
      assert {:error, :unconfirm} = result
    end

    test "it return error if email not found" do
      result = Accounts.authenticate_by_email_and_pass(
        "invalid@email.com", "password"
      )
      assert {:error, :not_found} = result
    end

    test "it return error if password incorrect" do
      result = Accounts.authenticate_by_email_and_pass(
        "test@example.com", "incorrect"
      )
      assert {:error, :unauthorized} = result
    end
  end

  describe "users" do
    setup do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      {:ok, user: user}
    end

    test "create_user/1 with valid create user and generate confirmation token", context do
      user = context[:user]

      assert user.email == "test@example.com"
      assert user.username == "test"
      assert user.confirmation_token != nil
    end


    test "confirm_user/1 return result.confirmed as true", context do
      user = context[:user]
      {:ok, result} = Accounts.confirm_user(user)
      assert result.confirmed
    end

    test "check_reset_password_token/1 with valid token return user", context do
      user = context[:user]
      {:ok, user} = Accounts.reset_password(user)

      token = user.reset_password_token
      {:ok, %Accounts.User{}} = Accounts.check_reset_password_token(token)
    end

    test "check_reset_password_token/1 with invalid token return error", context do
      user = context[:user]
      {:ok, _user} = Accounts.reset_password(user)

      token = "invalid token"
      {:error, :invalid} = Accounts.check_reset_password_token(token)
    end
  end
end
