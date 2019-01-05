defmodule TilWeb.Router do
  use TilWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TilWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

   if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
   end

  scope "/", TilWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/test", PageController, :test
    get "/register", AccountController, :new
    post "/register", AccountController, :create

    get "/accounts", AccountController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    pipe_through :authenticate_user
    resources "/posts", PostController
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
