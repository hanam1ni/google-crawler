defmodule GoogleCrawler.Keywords.KeywordTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.Keywords.Keyword

  describe "create_changeset/2" do
    test "returns valid changeset when given valid attributes" do
      keyword = build(:keyword, user: build(:user))

      changeset = Keyword.create_changeset(keyword, %{title: "Keyword title"})

      assert changeset.valid?
      assert changeset.changes.title == "Keyword title"
    end

    test "returns invalid changeset when required attributes are missing" do
      changeset = Keyword.create_changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{title: ["can't be blank"]}
    end
  end

  describe "update_result_page_html_changeset/2" do
    test "returns valid changeset when given valid attributes" do
      result_page_html = "<div>Result HTML Page</div>"

      changeset = Keyword.update_result_page_html_changeset(result_page_html)

      assert changeset.valid?
      assert changeset.changes.result_page_html == result_page_html
    end
  end

  describe "update_status_changeset/2" do
    test "returns valid changeset when given valid attributes" do
      changeset = Keyword.update_status_changeset("parse_completed")

      assert changeset.valid?
      assert changeset.changes.status == "parse_completed"
    end

    test "returns invaliad changeset when given invalid status" do
      changeset = Keyword.update_status_changeset("invalid_status")

      refute changeset.valid?
    end
  end
end
