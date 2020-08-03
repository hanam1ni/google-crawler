defmodule GoogleCrawlerWeb.KeywordController do
  require Logger
  require Ecto.Query

  use GoogleCrawlerWeb, :controller

  alias GoogleCrawler.Keyword
  alias GoogleCrawler.Repo
  alias GoogleCrawler.Scraper.Supervisor, as: ScraperSupervisor

  def index(conn, _params) do
    keywords =
      Keyword
      |> Ecto.Query.order_by([:id])
      |> Repo.all()

    render(conn, "index.html", keywords: keywords)
  end

  def new(conn, _params) do
    keyword = Keyword.changeset(%Keyword{}, %{})

    render(conn, "new.html", keyword: keyword)
  end

  def show(conn, %{"id" => keyword_id}) do
    keyword = Repo.get!(Keyword, keyword_id)

    render(conn, "show.html", keyword: keyword)
  end

  def create(conn, %{"keyword" => keyword_params}) do
    %Keyword{}
    |> Keyword.changeset(keyword_params)
    |> Repo.insert()
    |> case do
      {:ok, keyword} ->
        ScraperSupervisor.start_child([keyword])

        conn
        |> put_flash(:info, "Keyword created successfully.")
        |> redirect(to: Routes.keyword_path(conn, :show, keyword))

      {:error, changeset} ->
        Logger.info(inspect(changeset.errors))

        conn
        |> redirect(to: Routes.keyword_path(conn, :new))
    end
  end

  def delete(conn, %{"id" => keyword_id}) do
    keyword = Repo.get!(Keyword, keyword_id)

    Repo.delete(keyword)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Keyword deleted successfully.")
        |> redirect(to: Routes.keyword_path(conn, :index))

      {:error, keyword} ->
        Logger.info(inspect(keyword))

        conn
        |> redirect(to: Routes.keyword_path(conn, :index))
    end
  end
end