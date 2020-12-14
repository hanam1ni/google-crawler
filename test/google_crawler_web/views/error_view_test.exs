defmodule GoogleCrawlerWeb.ErrorViewTest do
  use GoogleCrawlerWeb.ViewCase, async: true

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

  test "renders error.json with changeset" do
    changeset = %Ecto.Changeset{
      errors: [title: {"can't be blank", [validation: :required]}],
      types: %{title: :string}
    }

    assert %{object: "error", code: :bad_request, details: %{title: ["can't be blank"]}} ==
             ErrorView.render("error.json", %{status: :bad_request, changeset: changeset})
  end
end
