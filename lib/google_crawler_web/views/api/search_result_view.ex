defmodule GoogleCrawlerWeb.Api.SearchResultView do
  use GoogleCrawlerWeb, :view

  def fields, do: [:url, :title]
  def type, do: "search_result"
end
