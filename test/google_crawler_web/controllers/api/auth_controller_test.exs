defmodule GoogleCrawlerWeb.Api.AuthControllerTest do
  use GoogleCrawlerWeb.ApiConnCase, async: true

  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.{Repo, Tokenizer}
  alias GoogleCrawlerWeb.Api.AuthController

  describe "callback/2" do
    test "creates user when token is valid and email does not exist", %{conn: conn} do
      auth_response = %{
        credentials: %{
          token: "AUTH_TOKEN"
        },
        info: %{
          email: "user@mail.com"
        }
      }

      conn =
        conn
        |> Plug.Conn.assign(:ueberauth_auth, auth_response)
        |> AuthController.call(:callback)

      assert %{
               "object" => "token",
               "access_token" => access_token
             } = json_response(conn, 200)

      {:ok, claims} = Tokenizer.decode_and_verify(access_token)

      user_in_db = Repo.get(User, claims["sub"])
      assert user_in_db.email == "user@mail.com"
      assert user_in_db.token == "AUTH_TOKEN"
      assert user_in_db.provider == "google"
    end

    test "returns access token when token is valid and found user with given email", %{conn: conn} do
      user = insert(:user, email: "user@mail.com", token: "AUTH_TOKEN")

      auth_response = %{
        credentials: %{
          token: "AUTH_TOKEN"
        },
        info: %{
          email: "user@mail.com"
        }
      }

      conn =
        conn
        |> Plug.Conn.assign(:ueberauth_auth, auth_response)
        |> AuthController.call(:callback)

      assert %{
               "object" => "token",
               "access_token" => access_token
             } = json_response(conn, 200)

      {:ok, claims} = Tokenizer.decode_and_verify(access_token)

      assert user.id == claims["sub"]
    end

    test "returns bad request when given invalid token", %{conn: conn} do
      _user = insert(:user, email: "user@mail.com", token: "AUTH_TOKEN")

      auth_response = %{
        credentials: %{
          token: "INVALID_TOKEN"
        },
        info: %{
          email: "user@mail.com"
        }
      }

      conn =
        conn
        |> Plug.Conn.assign(:ueberauth_auth, auth_response)
        |> AuthController.call(:callback)

      assert %{
               "object" => "error",
               "code" => "bad_request"
             } == json_response(conn, 400)
    end
  end
end
