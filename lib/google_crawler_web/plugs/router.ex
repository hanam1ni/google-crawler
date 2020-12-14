defmodule GoogleCrawlerWeb.Plugs.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  match("/api/*_", to: GoogleCrawlerWeb.ApiRouter)
  match(_, to: GoogleCrawlerWeb.Router)
end
