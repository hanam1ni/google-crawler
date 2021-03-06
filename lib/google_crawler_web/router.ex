defmodule GoogleCrawlerWeb.Router do
  use GoogleCrawlerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authentication do
    plug GoogleCrawlerWeb.Plugs.Authentication
  end

  pipeline :mock_oauth do
    plug GoogleCrawlerWeb.Plugs.Tests.MockOauth
  end

  scope "/", GoogleCrawlerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", GoogleCrawlerWeb do
    pipe_through :browser
    pipe_through :authentication

    resources "/keyword", KeywordController, only: [:index, :show, :new, :create, :delete]
    get "/keyword/:id/result_preview", KeywordController, :result_preview
    post "/keyword/import", KeywordController, :import, as: :keyword_import
  end

  scope "/auth", GoogleCrawlerWeb do
    pipe_through :browser

    if Mix.env() == :test do
      pipe_through :mock_oauth
    end

    delete "/", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GoogleCrawlerWeb.Telemetry
    end
  end
end
