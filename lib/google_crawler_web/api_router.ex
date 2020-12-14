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

  pipeline :json_api_deserialize do
    plug JSONAPI.Deserializer
    plug JSONAPI.UnderscoreParameters
  end

  scope "/api", GoogleCrawlerWeb.Api do
    pipe_through [:api, :authentication, :json_api_deserialize]

    resources "/keyword", KeywordController, only: [:index, :show, :create]
  end

  scope "/api", GoogleCrawlerWeb.Api do
    pipe_through :api

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
  end
end
