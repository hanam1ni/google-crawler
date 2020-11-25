defmodule GoogleCrawlerWeb.ErrorViewTest do
  use GoogleCrawlerWeb.ViewCase

  alias GoogleCrawlerWeb.ErrorView

  test "renders 404.html" do
    assert render_to_string(ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ErrorView, "500.html", []) == "Internal Server Error"
  end

  test "renders error.json" do
    assert %{object: "error", code: :unauthorized} ==
             ErrorView.render("error.json", %{status: :unauthorized})
  end
end
