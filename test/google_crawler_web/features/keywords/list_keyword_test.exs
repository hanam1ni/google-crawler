defmodule GoogleCrawlerWeb.ListKeywordTest do
  use GoogleCrawlerWeb.FeatureCase, async: true

  @selectors %{
    keyword_table_cell: ".table-keyword td"
  }

  feature "lists keywords for the given user", %{session: session} do
    user1 = insert(:user)
    user2 = insert(:user)
    keyword1 = insert(:keyword, user: user1)
    keyword2 = insert(:keyword, user: user1)
    keyword3 = insert(:keyword, user: user2)

    session
    |> login_as(user1)
    |> visit("/keyword")
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword1.title))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword2.title))
    |> refute_has(css(@selectors[:keyword_table_cell], text: keyword3.title))
  end
end
