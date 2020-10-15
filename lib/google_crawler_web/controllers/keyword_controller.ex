defmodule GoogleCrawlerWeb.KeywordController do
  use GoogleCrawlerWeb, :controller

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.Keyword

  def index(conn, _params) do
    keywords = Keywords.list_keywords(conn.assigns.user.id)

    render(conn, "index.html", keywords: keywords)
  end

  def new(conn, _params) do
    keyword = Keyword.create_changeset(%Keyword{}, %{})

    render(conn, "new.html", keyword: keyword)
  end

  def show(conn, %{"id" => keyword_id}) do
    keyword = Keywords.get_keyword_by_id(keyword_id)

    render(conn, "show.html", keyword: keyword)
  end

  def create(conn, %{"keyword" => keyword_params}) do
    keyword_params
    |> Map.put("user_id", conn.assigns.user.id)
    |> Keywords.create_keyword()
    |> case do
      {:ok, keyword} ->
        Keywords.scrape_keyword()

        conn
        |> put_flash(:info, "Keyword created successfully.")
        |> redirect(to: Routes.keyword_path(conn, :show, keyword))

      {:error, _changeset} ->
        conn
        |> redirect(to: Routes.keyword_path(conn, :new))
    end
  end

  def import(conn, %{"keywords" => keywords}) do
    keywords.path
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.each(fn [keyword_title] ->
      Keywords.create_keyword(%{title: keyword_title, user_id: conn.assigns.user.id})
      |> case do
        {:ok, keyword} -> keyword
      end
    end)

    Keywords.scrape_keyword()

    conn
    |> put_flash(:info, "Keyword uploaded successfully.")
    |> redirect(to: Routes.keyword_path(conn, :index))
  end

  def delete(conn, %{"id" => keyword_id}) do
    Keywords.delete_keyword(keyword_id)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Keyword deleted successfully.")
        |> redirect(to: Routes.keyword_path(conn, :index))

      {:error, _keyword} ->
        conn
        |> redirect(to: Routes.keyword_path(conn, :index))
    end
  end
end
