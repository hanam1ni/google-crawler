defmodule GoogleCrawlerWeb.Api.KeywordControllerTest do
  use GoogleCrawlerWeb.ApiConnCase, async: true

  alias GoogleCrawlerWeb.Api.KeywordController

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
end
