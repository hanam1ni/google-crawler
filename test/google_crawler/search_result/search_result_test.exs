defmodule GoogleCrawler.SearchResults.SearchResultTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.SearchResults.SearchResult

  describe "create_changeset/2" do
    test "returns valid changeset when given valid attributes" do
      keyword = insert(:keyword)

      attrs = %{
        url: "www.google.com",
        keyword_id: keyword.id,
        title: "Google result",
        is_ad: true,
        is_top_ad: true
      }

      changeset = SearchResult.create_changeset(attrs)

      assert changeset.valid?
      assert changeset.changes.url == "www.google.com"
      assert changeset.changes.keyword_id == keyword.id
      assert changeset.changes.title == "Google result"
      assert changeset.changes.is_ad == true
      assert changeset.changes.is_top_ad == true
    end

    test "returns invalid changeset when required attributes are missing" do
      changeset = SearchResult.create_changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               url: ["can't be blank"],
               keyword_id: ["can't be blank"],
               title: ["can't be blank"]
             }
    end
  end
end
