defmodule GoogleCrawler.Factory do
  use ExMachina.Ecto, repo: GoogleCrawler.Repo

  use GoogleCrawler.KeywordFactory
  use GoogleCrawler.SearchResults.SearchResultFactory
  use GoogleCrawler.UserFactory
end
