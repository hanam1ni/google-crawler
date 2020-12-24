defmodule GoogleCrawlerWeb.Api.KeywordControllerTest do
  use GoogleCrawlerWeb.ApiConnCase, async: true

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.{Keyword, ScraperSupervisor}
  alias GoogleCrawler.Repo

  describe "index/2" do
    test "returns the keywords for the given user", %{conn: conn} do
      user = insert(:user)
      other_user = insert(:user)
      %{title: keyword1_title, status: keyword1_status} = insert(:keyword, user: user)
      %{title: keyword2_title, status: keyword2_status} = insert(:keyword, user: user)
      _other_user_keyword = insert(:keyword, user: other_user, title: "Other user keyword")

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :index))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "status" => ^keyword1_status,
                     "title" => ^keyword1_title
                   },
                   "type" => "keyword"
                 },
                 %{
                   "attributes" => %{
                     "status" => ^keyword2_status,
                     "title" => ^keyword2_title
                   },
                   "type" => "keyword"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "filters the keywords with the given params", %{conn: conn} do
      %{id: user_id} = user = insert(:user)

      expect(Keywords, :list_keywords, fn ^user_id, %{"url" => ".com"} -> [] end)

      conn
      |> login_as(user)
      |> get(Routes.keyword_path(conn, :index), %{"keyword_filter" => %{"url" => ".com"}})

      verify!()
    end
  end

  describe "show/2" do
    test "returns the keyword with search results for the given keyword id", %{conn: conn} do
      user = insert(:user)
      %{title: keyword_title, status: keyword_status} = keyword = insert(:keyword, user: user)
      %{title: search_result1_title} = insert(:search_result, keyword: keyword)
      %{title: search_result2_title} = insert(:search_result, keyword: keyword)

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :show, keyword.id))

      assert %{
               "data" => %{
                 "attributes" => %{
                   "status" => ^keyword_status,
                   "title" => ^keyword_title
                 },
                 "type" => "keyword",
                 "relationships" => %{
                   "search_results" => %{
                     "data" => [
                       %{
                         "type" => "search_result"
                       },
                       %{
                         "type" => "search_result"
                       }
                     ]
                   }
                 }
               },
               "included" => [
                 %{
                   "attributes" => %{
                     "title" => ^search_result1_title
                   },
                   "type" => "search_result"
                 },
                 %{
                   "attributes" => %{
                     "title" => ^search_result2_title
                   },
                   "type" => "search_result"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "returns error if keyword not found", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :show, "999"))

      assert %{"code" => "not_found", "object" => "error"} = json_response(conn, 404)
    end

    test "returns error if keyword does not belong to the given user", %{conn: conn} do
      user = insert(:user)
      other_user = insert(:user)
      keyword = insert(:keyword, user: other_user)

      conn =
        conn
        |> login_as(user)
        |> get(Routes.keyword_path(conn, :show, keyword.id))

      assert %{"code" => "not_found", "object" => "error"} = json_response(conn, 404)
    end
  end

  describe "create/2" do
    test "creates keyword and starts scraping worker when given valid params", %{conn: conn} do
      user = insert(:user)

      params = %{
        "data" => %{
          "type" => "keyword",
          "attributes" => %{
            "title" => "rocket"
          }
        }
      }

      expect(ScraperSupervisor, :start_child, fn [%Keyword{title: "rocket"}] -> :ok end)

      conn =
        conn
        |> login_as(user)
        |> post(Routes.keyword_path(conn, :create), params)

      assert %{
               "data" => %{
                 "attributes" => %{
                   "title" => "rocket"
                 },
                 "type" => "keyword"
               }
             } = json_response(conn, 201)

      [keyword_in_db] = Repo.all(Keyword)
      assert keyword_in_db.title == "rocket"

      verify!()
    end

    test "returns error when given invalid params", %{conn: conn} do
      user = insert(:user)

      params = %{
        "data" => %{
          "type" => "keyword",
          "attributes" => %{
            "title" => ""
          }
        }
      }

      reject(ScraperSupervisor, :start_child, 1)

      conn =
        conn
        |> login_as(user)
        |> post(Routes.keyword_path(conn, :create), params)

      assert %{
               "code" => "bad_request",
               "details" => %{
                 "title" => [
                   "can't be blank"
                 ]
               },
               "object" => "error"
             } = json_response(conn, 400)

      assert [] = Repo.all(Keyword)

      verify!()
    end

    test "returns error when given invalid type", %{conn: conn} do
      user = insert(:user)

      params = %{
        "data" => %{
          "type" => "INVALID_TYPE",
          "attributes" => %{
            "title" => "rocket"
          }
        }
      }

      reject(ScraperSupervisor, :start_child, 1)

      conn =
        conn
        |> login_as(user)
        |> post(Routes.keyword_path(conn, :create), params)

      assert %{
               "code" => "bad_request",
               "object" => "error"
             } = json_response(conn, 400)

      assert [] = Repo.all(Keyword)

      verify!()
    end
  end

  describe "delete/2" do
    test "deletes user keyword when given valid keyword id", %{conn: conn} do
      user = insert(:user)
      keyword = insert(:keyword, user: user)

      conn =
        conn
        |> login_as(user)
        |> delete(Routes.keyword_path(conn, :delete, keyword))

      assert response(conn, 204)
    end

    test "returns error when given keyword does not belong to user", %{conn: conn} do
      user = insert(:user)
      other_user = insert(:user)
      keyword = insert(:keyword, user: other_user)

      conn =
        conn
        |> login_as(user)
        |> delete(Routes.keyword_path(conn, :delete, keyword))

      assert %{"code" => "not_found", "object" => "error"} = json_response(conn, 404)
    end

    test "returns error when given keyword does not exist", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> login_as(user)
        |> delete(Routes.keyword_path(conn, :delete, "999"))

      assert %{"code" => "not_found", "object" => "error"} = json_response(conn, 404)
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
end
