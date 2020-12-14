defmodule GoogleCrawlerWeb.ApiConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias GoogleCrawlerWeb.ApiRouter.Helpers, as: Routes

      use Mimic

      import Plug.Conn
      import Phoenix.ConnTest
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

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
