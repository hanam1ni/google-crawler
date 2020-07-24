defmodule GoogleCrawlerWeb.KeywordControllerTest do
  use GoogleCrawlerWeb.ConnCase
  use Mimic

  Mimic.copy(GoogleCrawler.Scraper.Supervisor)

  alias GoogleCrawler.Keyword
  alias GoogleCrawler.Repo

  describe "index/2" do
    test "renders the keyword list", %{conn: conn} do
      user = insert(:user)
      keywords = insert_list(2, :keyword)

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :index))

      keyword1 = Enum.fetch!(keywords, 0)
      keyword2 = Enum.fetch!(keywords, 1)
      assert html_response(conn, 200) =~ "#{keyword1.title}"
      assert html_response(conn, 200) =~ "#{keyword2.title}"
    end
  end

  describe "show/2" do
    test "renders the given keyword", %{conn: conn} do
      user = insert(:user)
      keyword = insert(:completed_scraped_keyword)

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

      GoogleCrawler.Scraper.Supervisor
      |> stub(:start_child, fn keyword -> keyword end)

      conn
      |> login_as(user)
      |> post(Routes.keyword_path(conn, :create), %{keyword: %{title: keyword_title}})

      created_keyword = Keyword |> Repo.all() |> Enum.fetch!(0)

      assert created_keyword.title == keyword_title
      assert created_keyword.status == Keyword.statuses().initial
    end

    test "starts the scraping worker with given keyword", %{conn: conn} do
      user = insert(:user)
      keyword_title = Faker.Lorem.word()

      GoogleCrawler.Scraper.Supervisor
      |> expect(:start_child, fn [%Keyword{title: ^keyword_title}] = keyword -> keyword end)

      conn
      |> login_as(user)
      |> post(Routes.keyword_path(conn, :create), %{keyword: %{title: keyword_title}})
    end
  end

  describe "delete/2" do
    test "deletes the given keyword", %{conn: conn} do
      user = insert(:user)
      keyword = insert(:completed_scraped_keyword)

      conn
      |> login_as(user)
      |> delete(Routes.keyword_path(conn, :delete, keyword))

      keywords = Keyword |> Repo.all()

      assert length(keywords) == 0
    end
  end
end
