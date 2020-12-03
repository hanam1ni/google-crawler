defmodule GoogleCrawlerWeb.ShowKeywordTest do
  use GoogleCrawlerWeb.FeatureCase, async: true

  @selectors %{
    keyword_title: "main h1",
    search_result_table_cell: "main .table-search-result td",
    notification: ".alert"
  }

  feature "shows keyword detail with search result", %{session: session} do
    user = insert(:user)
    keyword = insert(:keyword, user: user)
    search_result1 = insert(:search_result, keyword: keyword)
    search_result2 = insert(:search_result, keyword: keyword)

    session
    |> login_as(user)
    |> visit("/keyword/#{keyword.id}")
    |> assert_has(css(@selectors[:keyword_title], text: keyword.title))
    |> assert_has(css(@selectors[:search_result_table_cell], text: search_result1.title))
    |> assert_has(css(@selectors[:search_result_table_cell], text: search_result2.title))
  end

  feature "redirects to keyword list page with error message if keyword is not found", %{
    session: session
  } do
    user = insert(:user)
    other_user = insert(:user)
    keyword = insert(:keyword, user: other_user)

    session
    |> login_as(user)
    |> visit("/keyword/#{keyword.id}")
    |> assert_has(css(@selectors[:notification], text: "Keyword not found."))

    assert "/keyword" == current_path(session)
  end
end
