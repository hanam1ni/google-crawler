defmodule GoogleCrawler.Factory do
  use ExMachina.Ecto, repo: GoogleCrawler.Repo
  
  use GoogleCrawler.KeywordFactory
  use GoogleCrawler.SearchResultFactory
end