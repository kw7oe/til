defmodule Til.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Hound.Helpers
      alias Til.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias TilWeb.Router.Helpers, as: Routes

      @endpoint TilWeb.Endpoint

      import Til.Factory

      hound_session()
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Til.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Til.Repo, {:shared, self()})
    end

    :ok
  end
end
