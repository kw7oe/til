defmodule UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  def find_or_create(%Auth{provider: :identity} = auth) do
    case validate_pass(auth.credentials) do
      :ok ->
        {:ok, social_info(auth)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def find_or_create(%Auth{} = auth) do
    {:ok, social_info(auth)}
  end

  def connect(%Auth{} = auth, user) do
    Til.Accounts.update_user(user, social_info(auth))
  end

  # GitHub
  defp avatar_from_auth(%{info: %{urls: %{avatar_url: image}}}), do: image

  defp avatar_from_auth(auth) do
    Logger.warn(auth.provider <> " needs to find an avatar URL!")
    Logger.debug(Jason.encode!(auth))
    nil
  end

  # GitHub
  defp handle_from_auth(%{info: %{nickname: handle}}), do: handle

  defp handle_from_auth(auth) do
    Logger.warn(auth.provider <> " needs to find an avatar URL!")
    Logger.debug(Jason.encode!(auth))
    nil
  end

  defp social_info(auth) do
    %{github_handle: handle_from_auth(auth), avatar: avatar_from_auth(auth)}
  end

  defp validate_pass(%{other: %{password: ""}}) do
    {:error, "Password required"}
  end

  defp validate_pass(%{other: %{password: pw, password_confirmation: pw}}) do
    :ok
  end

  defp validate_pass(%{other: %{password: _}}) do
    {:error, "Passwords do not match"}
  end

  defp validate_pass(_), do: {:error, "Password Required"}
end
