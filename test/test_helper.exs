ExUnit.start()
Faker.start()
Application.ensure_all_started(:wallaby)

Ecto.Adapters.SQL.Sandbox.mode(GoogleCrawler.Repo, :manual)

Application.put_env(:wallaby, :base_url, GoogleCrawlerWeb.Endpoint.url())

Mimic.copy(GoogleCrawler.Keywords)
Mimic.copy(GoogleCrawler.Keywords.ScraperSupervisor)
Mimic.copy(GoogleCrawler.SearchResults.ParserSupervisor)
