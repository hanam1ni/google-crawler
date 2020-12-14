defmodule GoogleCrawlerWeb.Api.AuthView do
  use GoogleCrawlerWeb, :view

  def render("token.json", %{access_token: access_token}) do
    %{
      object: "token",
      access_token: access_token
    }
  end
end
