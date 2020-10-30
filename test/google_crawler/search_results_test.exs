defmodule GoogleCrawler.SearchResultsTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.SearchResults
  alias GoogleCrawler.SearchResults.SearchResult

  describe "create_search_result/2" do
    test "creates search result if given valid attribute" do
      keyword = insert(:keyword)

      attrs = %{
        url: "www.google.com",
        keyword_id: keyword.id,
        title: "Google result",
        is_ad: true,
        is_top_ad: true
      }

      {:ok, search_result} = SearchResults.create_search_result(attrs)

      assert search_result.title == attrs.title
      [search_result_in_db] = Repo.all(SearchResult)
      assert search_result_in_db.url == attrs.url
      assert search_result_in_db.keyword_id == keyword.id
      assert search_result_in_db.title == attrs.title
      assert search_result_in_db.is_ad == true
      assert search_result_in_db.is_top_ad == true
    end

    test "returns {:error, changeset} if given invalid attribute" do
      {:error, changeset} = SearchResults.create_search_result(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               url: ["can't be blank"],
               keyword_id: ["can't be blank"],
               title: ["can't be blank"]
             }
    end
  end
end
