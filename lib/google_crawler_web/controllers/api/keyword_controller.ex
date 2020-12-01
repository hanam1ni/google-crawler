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

  def show(conn, %{"id" => keyword_id}) do
    case Keywords.get_keyword_by_id(keyword_id) do
      nil ->
        ErrorHandler.handle(conn, :not_found)

      keyword ->
        conn
        |> put_status(:ok)
        |> render("show.json", %{data: keyword, conn: conn})
    end
  end
end
