defmodule GoogleCrawlerWeb.ErrorHandlerTest do
  use GoogleCrawlerWeb.ConnCase, async: true

  alias GoogleCrawlerWeb.ErrorHandler

  describe "handle/2" do
    test "renders error view with the given error status code", %{conn: conn} do
      conn = ErrorHandler.handle(conn, :unauthorized)

      assert json_response(conn, 401) == %{
               "object" => "error",
               "code" => "unauthorized"
             }
    end
  end

  describe "auth_error/3" do
    test "renders forbidden error view", %{conn: conn} do
      conn = ErrorHandler.auth_error(conn, {:unauthenticated, :unauthenticated}, [])

      assert json_response(conn, 403) == %{
               "object" => "error",
               "code" => "forbidden"
             }
    end
  end
end
