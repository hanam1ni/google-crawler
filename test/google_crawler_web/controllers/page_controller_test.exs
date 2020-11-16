defmodule GoogleCrawlerWeb.PageControllerTest do
  use GoogleCrawlerWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "GoogleCrawler"
  end
end
