defmodule GoogleCrawlerWeb.KeywordControllerTest do
  use GoogleCrawlerWeb.ConnCase, async: true

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.Repo

  describe "index/2" do
    test "renders the keywords for the given user", %{conn: conn} do
      user = insert(:user)
      other_user = insert(:user)
      keywords = insert_list(2, :keyword, user: user)
      other_user_keyword = insert(:keyword, user: other_user, title: "Other user keyword")

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :index))

      keyword1 = Enum.fetch!(keywords, 0)
      keyword2 = Enum.fetch!(keywords, 1)
      assert html_response(conn, 200) =~ "#{keyword1.title}"
      assert html_response(conn, 200) =~ "#{keyword2.title}"
      refute html_response(conn, 200) =~ "#{other_user_keyword.title}"
    end

    test "filters the keywords with the given params", %{conn: conn} do
      %{id: user_id} = user = insert(:user)

      expect(Keywords, :list_keywords, fn ^user_id, %{"url" => ".com"} -> [] end)

      conn
      |> login_as(user)
      |> get(Routes.keyword_path(conn, :index), %{"url" => ".com"})

      verify!()
    end
  end

  describe "show/2" do
    test "renders the given keyword", %{conn: conn} do
      user = insert(:user)
      keyword = insert(:completed_scraped_keyword, user: user)

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :show, keyword))

      assert html_response(conn, 200) =~ "#{keyword.title}"
      assert html_response(conn, 200) =~ "#{keyword.result_page_html}"
    end
  end

  describe "create/2" do
    test "creates the keyword", %{conn: conn} do
      user = insert(:user)
      keyword_title = Faker.Lorem.word()

      GoogleCrawler.Keywords.ScraperSupervisor
      |> stub(:start_child, fn keyword -> keyword end)

      conn
      |> login_as(user)
      |> post(Routes.keyword_path(conn, :create), %{title: keyword_title})

      [created_keyword] = Keyword |> Repo.all()

      assert created_keyword.title == keyword_title
      assert created_keyword.status == Keyword.statuses().initial
    end

    test "starts the scraper worker with given keyword", %{conn: conn} do
      user = insert(:user)
      keyword_title = Faker.Lorem.word()

      GoogleCrawler.Keywords.ScraperSupervisor
      |> expect(:start_child, fn [%Keyword{title: ^keyword_title}] = keyword -> keyword end)

      conn
      |> login_as(user)
      |> post(Routes.keyword_path(conn, :create), %{title: keyword_title})
    end
  end

  describe "import/2" do
    test "creates the keywords from uploaded keywords", %{conn: conn} do
      user = insert(:user)

      uploaded_keywords = %Plug.Upload{
        path: "test/support/fixtures/data/keywords.csv",
        filename: "keywords.csv"
      }

      GoogleCrawler.Keywords.ScraperSupervisor
      |> stub(:start_child, fn keyword -> keyword end)

      conn
      |> login_as(user)
      |> post(Routes.keyword_import_path(conn, :import), %{keywords: uploaded_keywords})

      keywords = Keyword |> Repo.all()

      assert length(keywords) == 3
    end
  end

  describe "delete/2" do
    test "deletes the given keyword", %{conn: conn} do
      user = insert(:user)
      keyword = insert(:completed_scraped_keyword, user: user)

      conn
      |> login_as(user)
      |> delete(Routes.keyword_path(conn, :delete, keyword))

      keywords = Keyword |> Repo.all()

      assert length(keywords) == 0
    end
  end
end
