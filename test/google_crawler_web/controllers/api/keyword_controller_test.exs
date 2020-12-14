defmodule GoogleCrawlerWeb.Api.KeywordControllerTest do
  use GoogleCrawlerWeb.ApiConnCase, async: true

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
end
