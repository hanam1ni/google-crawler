defmodule GoogleCrawlerWeb.Api.KeywordController do
  use GoogleCrawlerWeb, :controller

  alias GoogleCrawler.Keywords
  alias GoogleCrawlerWeb

  def index(conn, _params) do
    keywords = Keywords.list_keywords(conn.assigns.user.id, %{})

    conn
    |> put_status(:ok)
    |> render("index.json", %{data: keywords, conn: conn})
  end
end
