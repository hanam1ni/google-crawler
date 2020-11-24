defmodule GoogleCrawlerWeb.ErrorHandler do
  use Phoenix.Controller

  alias GoogleCrawlerWeb.ErrorView

  def handle(conn, status) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", status: status)
    |> halt()
  end

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> handle(:forbidden)
  end
end
