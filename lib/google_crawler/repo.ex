defmodule GoogleCrawler.Repo do
  use Ecto.Repo,
    otp_app: :google_crawler,
    adapter: Ecto.Adapters.Postgres
end
