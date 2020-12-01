defmodule GoogleCrawlerWeb.Api.KeywordView do
  use GoogleCrawlerWeb, :view

  def fields, do: [:title, :status]

  def relationships do
    [search_results: {GoogleCrawlerWeb.Api.SearchResultView, :include}]
  end

  def type, do: "keyword"
end
