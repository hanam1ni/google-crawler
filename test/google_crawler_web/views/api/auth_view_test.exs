defmodule GoogleCrawlerWeb.Api.AuthViewTest do
  use GoogleCrawlerWeb.ViewCase

  alias GoogleCrawlerWeb.Api.AuthView

  describe "render/2" do
    test "renders token.json" do
      assert %{
               object: "token",
               access_token: "USER_ACCESS_TOKEN"
             } ==
               AuthView.render("token.json", %{access_token: "USER_ACCESS_TOKEN"})
    end
  end
end
