defmodule GoogleCrawler.KeywordTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.Keyword

  describe "with_result_report/1" do
    test "returns keyword with result report" do
      search_results = insert_list(2, :search_result)
      ad_search_results = insert_list(2, :ad_search_result)
      top_ad_search_results = insert_list(1, :top_ad_search_result)

      keyword =
        insert(:keyword,
          search_results: search_results ++ ad_search_results ++ top_ad_search_results
        )

      keyword =
        Keyword
        |> Keyword.with_result_report()
        |> Repo.get!(keyword.id)

      assert keyword.result_count == 5
      assert keyword.ad_count == 3
      assert keyword.top_ad_count == 1
    end
  end
end
