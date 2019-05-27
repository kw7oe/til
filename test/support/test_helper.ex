defmodule TilWeb.TestHelper do
  use ExUnit.CaseTemplate

  using do
    quote do
      def login(conn, user) do
        assign(conn, :current_user, user)
      end
    end
  end
end
