defmodule GoogleCrawlerWeb.Api.AuthView do
  use GoogleCrawlerWeb, :view

  def render("token.json", %{}) do
    %{
      "access_token" => "User Access Token",
      "refresh_token" => "User Refresh Token"
    }
  end
end
