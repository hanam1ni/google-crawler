defmodule GoogleCrawlerWeb.Api.KeywordController do
  use GoogleCrawlerWeb, :controller

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.KeywordImporter
  alias GoogleCrawlerWeb

  def index(conn, params) do
    keywords = Keywords.list_keywords(conn.assigns.user.id, params["keyword_filter"])

    conn
    |> put_status(:ok)
    |> render("index.json", %{data: keywords, conn: conn})
  end

  def show(conn, %{"id" => keyword_id}) do
    case Keywords.get_keyword_for_user(conn.assigns.user.id, keyword_id) do
      nil ->
        ErrorHandler.handle(conn, :not_found)

      keyword ->
        conn
        |> put_status(:ok)
        |> render("show.json", %{data: keyword, conn: conn})
    end
  end

  def create(conn, %{"type" => "keyword"} = keyword_params) do
    keyword_params
    |> Map.put("user_id", conn.assigns.user.id)
    |> Keywords.create_keyword()
    |> case do
      {:ok, keyword} ->
        Keywords.scrape_keyword()

        conn
        |> put_status(:created)
        |> render("show.json", %{data: keyword, conn: conn})

      {:error, changeset} ->
        ErrorHandler.handle(conn, :bad_request, changeset)
    end
  end

  def create(conn, _), do: ErrorHandler.handle(conn, :bad_request)

  def delete(conn, %{"id" => keyword_id}) do
    case Keywords.get_keyword_for_user(conn.assigns.user.id, keyword_id) do
      nil ->
        ErrorHandler.handle(conn, :not_found)

      keyword ->
        Keywords.delete_keyword(keyword)

        send_resp(conn, :no_content, "")
    end
  end

  def import(conn, %{"keywords" => keywords}) do
    user_id = conn.assigns.user.id

    case KeywordImporter.import(keywords, user_id) do
      {:ok, _} ->
        Keywords.scrape_keyword()

        send_resp(conn, :no_content, "")

      {:error, _} ->
        ErrorHandler.handle(conn, :bad_request)
    end
  end
end
