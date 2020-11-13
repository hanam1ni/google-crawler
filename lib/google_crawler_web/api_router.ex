defmodule GoogleCrawlerWeb.ApiRouter do
  use GoogleCrawlerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GoogleCrawlerWeb.Api do
    pipe_through :api

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
  end
end
