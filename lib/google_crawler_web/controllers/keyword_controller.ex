defmodule GoogleCrawlerWeb.KeywordController do
  use GoogleCrawlerWeb, :controller

  alias GoogleCrawler.Keywords

  def index(conn, params) do
    keywords = Keywords.list_keywords(conn.assigns.user.id, params["keyword_filter"])

    render(conn, "index.html", keywords: keywords, params: params)
  end

  def new(conn, _params), do: render(conn, "new.html")

  def show(conn, %{"id" => keyword_id}) do
    case Keywords.get_keyword_for_user(conn.assigns.user.id, keyword_id) do
      nil ->
        conn
        |> put_flash(:error, "Keyword not found.")
        |> redirect(to: Routes.keyword_path(conn, :index))

      keyword ->
        render(conn, "show.html", keyword: keyword)
    end
  end

  def create(conn, keyword_params) do
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
    case Keywords.get_keyword_for_user(conn.assigns.user.id, keyword_id) do
      nil ->
        conn
        |> put_flash(:error, "Something went wrong, please try again")
        |> redirect(to: Routes.keyword_path(conn, :index))

      keyword ->
        Keywords.delete_keyword(keyword)

        conn
        |> put_flash(:info, "Keyword deleted successfully.")
        |> redirect(to: Routes.keyword_path(conn, :index))
    end
  end

  def result_preview(conn, %{"id" => keyword_id}) do
    case Keywords.get_keyword_for_user(conn.assigns.user.id, keyword_id) do
      nil ->
        conn
        |> put_flash(:error, "Keyword not found.")
        |> redirect(to: Routes.keyword_path(conn, :index))

      keyword ->
        conn
        |> put_layout(false)
        |> render("result_preview.html", result_page_html: keyword.result_page_html)
    end
  end
end
