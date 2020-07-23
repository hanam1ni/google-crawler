defmodule GoogleCrawlerWeb.PageController do
  use GoogleCrawlerWeb, :controller

  plug :put_layout, "landing.html"

  alias GoogleCrawler.Repo
  alias GoogleCrawler.User

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user_id do
      redirect(conn, to: Routes.keyword_path(conn, :index))
    else
      render(conn, "index.html")
    end
  end
end
