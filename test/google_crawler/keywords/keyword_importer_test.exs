defmodule GoogleCrawler.Keywords.KeywordImporterTest do
  use GoogleCrawler.DataCase, async: true

  alias GoogleCrawler.Keywords.{Keyword, KeywordImporter}

  describe "import/2" do
    test "creates keyword from given CSV file" do
      user = insert(:user)

      assert {:ok, _} =
               KeywordImporter.import(
                 %{content_type: "text/csv", path: "test/support/fixtures/data/keywords.csv"},
                 user.id
               )

      [keyword1_in_db, keyword2_in_db, keyword3_in_db] = Repo.all(Keyword)

      assert keyword1_in_db.title == "apple"
      assert keyword1_in_db.user_id == user.id
      assert keyword2_in_db.title == "orange"
      assert keyword2_in_db.user_id == user.id
      assert keyword3_in_db.title == "pineapple"
      assert keyword3_in_db.user_id == user.id
    end

    test "returns error and does not create keyword if given invalid CSV file format" do
      user = insert(:user)

      assert {:error, "Failed to import keywords."} =
               KeywordImporter.import(
                 %{
                   content_type: "text/csv",
                   path: "test/support/fixtures/data/invalid_keywords.csv"
                 },
                 user.id
               )

      assert Repo.all(Keyword) == []
    end

    test "returns error and does not create keyword if given invalid file type" do
      user = insert(:user)

      assert {:error, "Invalid file type."} =
               KeywordImporter.import(%{content_type: "application/pdf"}, user.id)

      assert Repo.all(Keyword) == []
    end
  end
end
