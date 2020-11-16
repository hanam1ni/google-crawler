ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(GoogleCrawler.Repo, :manual)

Mimic.copy(GoogleCrawler.Keywords)
Mimic.copy(GoogleCrawler.Keywords.ScraperSupervisor)
Mimic.copy(GoogleCrawler.SearchResults.ParserSupervisor)
