defmodule GoogleCrawlerWeb.FilterKeywordTest do
  use GoogleCrawlerWeb.FeatureCase, async: true

  @selectors %{
    keyword_table_cell: ".table-keyword td",
    button_keyword_filter: "a[href='#keywordFilter']",
    button_submit_filter: "#keywordFilter button[type='submit']",
    input_title_filter: "input[name='keyword_filter[title]']",
    input_url_filter: "input[name='keyword_filter[url]']",
    equal_option_result_count_filter: "select[name='keyword_filter[result_count_operation]'] option[value='=']",
    input_result_count_filter: "input[name='keyword_filter[result_count_value]']",
  }

  feature "filters keywords contain title by the given title", %{session: session} do
    user = insert(:user)
    keyword1 = insert(:keyword, title: "apple", user: user)
    keyword2 = insert(:keyword, title: "rocket", user: user)
    keyword3 = insert(:keyword, title: "rock climbing", user: user)

    session
    |> login_as(user)
    |> visit("/keyword")
    |> click(css(@selectors[:button_keyword_filter]))
    |> fill_in(css(@selectors[:input_title_filter]), with: "rock")
    |> click(css(@selectors[:button_submit_filter]))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword2.title))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword3.title))
    |> refute_has(css(@selectors[:keyword_table_cell], text: keyword1.title))
  end

  feature "filters keywords contain result url by the given url", %{session: session} do
    user = insert(:user)
    keyword1 = insert(:keyword, user: user)
    keyword2 = insert(:keyword, user: user)
    keyword3 = insert(:keyword, user: user)

    insert(:search_result, keyword: keyword1, url: "www.example.com")
    insert(:search_result, keyword: keyword2, url: "www.example.com/detail")
    insert(:search_result, keyword: keyword3, url: "www.example.co.th")

    session
    |> login_as(user)
    |> visit("/keyword")
    |> click(css(@selectors[:button_keyword_filter]))
    |> fill_in(css(@selectors[:input_url_filter]), with: "example.com")
    |> click(css(@selectors[:button_submit_filter]))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword1.title))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword2.title))
    |> refute_has(css(@selectors[:keyword_table_cell], text: keyword3.title))
  end

  feature "filters keywords which search results match amount and operation by the given params", %{session: session} do
    user = insert(:user)
    keyword1 = insert(:keyword, user: user)
    keyword2 = insert(:keyword, user: user)

    insert(:search_result, keyword: keyword1)
    insert(:search_result, keyword: keyword1)

    session
    |> login_as(user)
    |> visit("/keyword")
    |> click(css(@selectors[:button_keyword_filter]))
    |> click(css(@selectors[:equal_option_result_count_filter]))
    |> fill_in(css(@selectors[:input_result_count_filter]), with: "2")
    |> click(css(@selectors[:button_submit_filter]))
    |> assert_has(css(@selectors[:keyword_table_cell], text: keyword1.title))
    |> refute_has(css(@selectors[:keyword_table_cell], text: keyword2.title))
  end
end
