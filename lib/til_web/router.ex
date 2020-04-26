defmodule TilWeb.Router do
  use TilWeb, :router
  import Phoenix.LiveDashboard.Router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ueberauth
    plug TilWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end
  end

  scope "/", TilWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about

    get "/confirmation/:token", ConfirmationController, :new
    resources "/resend_confirmation", ResendConfirmationController, only: [:new, :create]

    get "/reset_password/new", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/token/:token", ResetPasswordController, :edit
    put "/reset_password/token/:token", ResetPasswordController, :update

    get "/register", UserController, :new
    post "/register", UserController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    get "/profile/edit", UserController, :edit
    put "/profile/edit", UserController, :update

    get "/password/edit", PasswordController, :edit
    put "/password/edit", PasswordController, :update

    resources "/users", UserController, only: [:show]
    resources "/tags", TagController, only: [:index, :show]
    resources "/posts", PostController

    get "/statistic", StatisticController, :show
    get "/posts/:id/export", ExportController, :export
    get "/export_posts", ExportController, :export_all
    get "/download/:tarfile", ExportController, :download
    post "/search", SearchController, :create
  end

  scope "/auth", TilWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", TilWeb do
  #   pipe_through :api
  # end
end
