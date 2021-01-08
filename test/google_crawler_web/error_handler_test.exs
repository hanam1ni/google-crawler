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

  describe "handle/3" do
    test "renders error view with the given error status code and changeset", %{conn: conn} do
      changeset = %Ecto.Changeset{
        errors: [title: {"can't be blank", [validation: :required]}],
        types: %{title: :string}
      }

      conn = ErrorHandler.handle(conn, :unauthorized, changeset)

      assert json_response(conn, 401) == %{
               "object" => "error",
               "code" => "unauthorized",
               "details" => %{"title" => ["can't be blank"]}
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

  describe "full_message/1" do
    test "returns formatted error message" do
      changeset = %Ecto.Changeset{
        errors: [
          title:
            {"should be at least %{count} characters", [count: 6, validation: :length, min: 6]},
          user_id: {"can't be blank", []}
        ],
        types: %{title: :string, user_id: :string}
      }

      assert ErrorHandler.full_message(changeset) ===
               "Title should be at least 6 characters, User can't be blank"
    end
  end
end
