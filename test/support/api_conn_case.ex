defmodule GoogleCrawlerWeb.ApiConnCase do
  use ExUnit.CaseTemplate

  alias GoogleCrawler.Tokenizer

  using do
    quote do
      alias GoogleCrawlerWeb.ApiRouter.Helpers, as: Routes

      use Mimic

      import Plug.Conn
      import Phoenix.ConnTest
      import GoogleCrawlerWeb.ApiConnCase
      import GoogleCrawler.Factory

      # The default endpoint for testing
      @endpoint GoogleCrawlerWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(GoogleCrawler.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(GoogleCrawler.Repo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  def login_as(conn, user) do
    {:ok, access_token, _} = Tokenizer.generate_access_token(user)

    conn
    |> Plug.Conn.put_req_header("authorization", "bearer: " <> access_token)
  end
end
