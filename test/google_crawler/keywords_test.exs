defmodule GoogleCrawler.KeywordsTest do
  use GoogleCrawler.DataCase, async: true

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.{Keyword, ScraperSupervisor}

  describe "create_keyword/2" do
    test "creates keyword if given valid attribute" do
      user = insert(:user)
      attrs = %{title: "Keyword title", user_id: user.id}

      {:ok, keyword} = Keywords.create_keyword(attrs)

      assert keyword.title == attrs.title
      [keyword_in_db] = Repo.all(Keyword)
      assert keyword_in_db.title == attrs.title
      assert keyword_in_db.user_id == user.id
    end

    test "returns {:error, changeset} if given invalid attribute" do
      {:error, changeset} = Keywords.create_keyword(%{})

      refute changeset.valid?
      assert errors_on(changeset) == %{title: ["can't be blank"], user_id: ["can't be blank"]}
    end
  end

  describe "delete_keyword/1" do
    test "deletes the given keyword" do
      keyword = insert(:keyword)

      {:ok, _} = Keywords.delete_keyword(keyword.id)

      assert [] = Repo.all(Keyword)
    end

    test "raises errors if the given keyword does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Keywords.delete_keyword(999) end
    end
  end

  describe "list_keywords/1" do
    test "lists keyword for the given user order by keyword id" do
      user1 = insert(:user)
      user2 = insert(:user)
      keyword1 = insert(:keyword, user: user1)
      keyword2 = insert(:keyword, user: user1)
      insert(:keyword, user: user2)

      [keyword1_in_db, keyword2_in_db] = Keywords.list_keywords(user1.id, %{})

      assert keyword1_in_db.id == keyword1.id
      assert keyword1_in_db.user_id == user1.id
      assert keyword2_in_db.id == keyword2.id
      assert keyword2_in_db.user_id == user1.id
    end

    test "lists keyword with result report" do
      user = insert(:user)
      keyword = insert(:keyword, user: user)
      insert(:search_result, keyword: keyword)
      insert(:ad_search_result, keyword: keyword)
      insert(:top_ad_search_result, keyword: keyword)

      [keyword_in_db] = Keywords.list_keywords(user.id, %{})

      assert keyword_in_db.result_count == 3
      assert keyword_in_db.ad_count == 2
      assert keyword_in_db.top_ad_count == 1
    end

    test "filters keywords which contain matched URL search result if given URL in params" do
      user = insert(:user)
      keyword1 = insert(:keyword, user: user)
      keyword2 = insert(:keyword, user: user)
      insert(:search_result, url: "example1.com", keyword: keyword1)
      insert(:search_result, url: "example2.net", keyword: keyword2)

      [keyword1_in_db] = Keywords.list_keywords(user.id, %{"url" => ".com"})

      assert keyword1_in_db.id == keyword1.id
    end
  end

  describe "get_keyword_for_user/1" do
    test "returns keyword by the given id and user id" do
      user = insert(:user)
      keyword = insert(:keyword, user: user)

      result_keyword = Keywords.get_keyword_for_user(user.id, keyword.id)

      assert result_keyword.id == keyword.id
      assert result_keyword.title == keyword.title
      assert result_keyword.user_id == user.id
    end

    test "returns with result report and preloads search_results" do
      user = insert(:user)
      keyword = insert(:keyword, user: user)
      insert(:search_result, keyword: keyword)
      insert(:ad_search_result, keyword: keyword)
      insert(:top_ad_search_result, keyword: keyword)

      result_keyword = Keywords.get_keyword_for_user(user.id, keyword.id)

      assert length(result_keyword.search_results) == 3
      assert result_keyword.result_count == 3
      assert result_keyword.ad_count == 2
      assert result_keyword.top_ad_count == 1
    end

    test "returns nil if keyword not found" do
      user = insert(:user)

      assert nil == Keywords.get_keyword_for_user(user.id, "999")
    end

    test "returns nil if keyword does not belong to the given user" do
      user1 = insert(:user)
      user2 = insert(:user)
      keyword = insert(:keyword, user: user2)

      assert nil == Keywords.get_keyword_for_user(user1.id, keyword.id)
    end
  end

  describe "scrape_keyword/0" do
    test "starts scraper worker with initial status keywords" do
      %{id: keyword1_id} = insert(:keyword, status: Keyword.statuses().initial)
      %{id: keyword2_id} = insert(:keyword, status: Keyword.statuses().initial)
      insert(:keyword, status: Keyword.statuses().scrape_completed)

      expect(ScraperSupervisor, :start_child, fn [
                                                   %Keyword{id: ^keyword1_id},
                                                   %Keyword{id: ^keyword2_id}
                                                 ] ->
        :ok
      end)

      Keywords.scrape_keyword()

      verify!()
    end
  end

  describe "update_keyword_result/2" do
    test "sets keyword status to scrape_completed and updates the keyword with the given result" do
      keyword = insert(:keyword, status: Keyword.statuses().initial)

      {:ok, updated_keyword} = Keywords.update_keyword_result(keyword, "Result HTML")

      assert updated_keyword.result_page_html == "Result HTML"
      [keyword_in_db] = Repo.all(Keyword)
      assert keyword_in_db.status == "scrape_completed"
      assert keyword_in_db.result_page_html == "Result HTML"
    end
  end

  describe "update_keyword_status/2" do
    test "updates the keyword with the given status" do
      keyword = insert(:keyword, status: Keyword.statuses().initial)

      updated_keyword = Keywords.update_keyword_status(keyword, "scrape_completed")

      assert updated_keyword.status == "scrape_completed"
      [keyword_in_db] = Repo.all(Keyword)
      assert keyword_in_db.status == "scrape_completed"
    end
  end
end
