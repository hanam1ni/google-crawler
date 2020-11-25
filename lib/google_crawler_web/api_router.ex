defmodule GoogleCrawlerWeb.ApiRouter do
  use GoogleCrawlerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication do
    plug Guardian.Plug.Pipeline,
      module: GoogleCrawler.Tokenizer,
      error_handler: GoogleCrawlerWeb.ErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
    plug GoogleCrawlerWeb.Plugs.ApiAuthentication
  end

  scope "/api", GoogleCrawlerWeb.Api do
    pipe_through [:api, :authentication]

    # For authenticated route
  end

  scope "/api", GoogleCrawlerWeb.Api do
    pipe_through :api

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
  end
end
