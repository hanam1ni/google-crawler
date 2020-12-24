defmodule GoogleCrawlerWeb.PreviewResultPageTest do
  use GoogleCrawlerWeb.FeatureCase, async: true

  @selectors %{
    title: "h1",
    result_item: "p"
  }

  feature "renders page from the HTML result page", %{session: session} do
    user = insert(:user)

    keyword =
      insert(:keyword, user: user, result_page_html: "<h1>Search result</h1><p>Result1</p>")

    session
    |> login_as(user)
    |> visit("/keyword/#{keyword.id}/result_preview")
    |> assert_has(css(@selectors[:title], text: "Search result"))
    |> assert_has(css(@selectors[:result_item], text: "Result1"))
  end
end
