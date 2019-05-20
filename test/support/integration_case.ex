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

      setup do
        # When using Chrome Headless, it has the window size of a mobile devices.
        #
        # We resize the window to carry out UI testing in a desktop
        # breakpoint so some elements will be present without the need of toggling
        # additional element.
        set_window_size(current_window_handle(), 1280, 720)

        :ok
      end
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
