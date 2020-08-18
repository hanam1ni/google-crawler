defmodule GoogleCrawlerWeb.PageController do
  use GoogleCrawlerWeb, :controller

  plug :put_layout, "landing.html"

  def index(conn, _params) do
    user = get_session(conn, :user)

    if user do
      redirect(conn, to: Routes.keyword_path(conn, :index))
    else
      render(conn, "index.html")
    end
  end
end
