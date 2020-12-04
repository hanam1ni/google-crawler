defmodule GoogleCrawlerWeb.Plugs.ApiAuthenticationTest do
  use GoogleCrawlerWeb.ConnCase, async: true

  alias GoogleCrawlerWeb.Plugs.ApiAuthentication

  describe "call/2" do
    test "assigns current user to assigns map", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> Plug.Conn.put_private(:guardian_default_resource, user)
        |> ApiAuthentication.call([])

      assert conn.assigns == %{user: user}
    end

    test "returns unauthorized error if no resource loaded", %{conn: conn} do
      conn =
        conn
        |> ApiAuthentication.call([])

      assert %{
               "object" => "error",
               "code" => "unauthorized"
             } == json_response(conn, 401)
    end
  end
end
