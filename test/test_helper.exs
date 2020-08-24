ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(GoogleCrawler.Repo, :manual)

Mimic.copy(GoogleCrawler.SearchResults.ParserSupervisor)
Mimic.copy(GoogleCrawler.Keywords.ScraperSupervisor)
