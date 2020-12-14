defmodule GoogleCrawlerWeb.Api.SearchResultView do
  use GoogleCrawlerWeb, :view

  def fields, do: [:url, :title, :is_ad, :is_top_ad]
  def type, do: "search_result"
end
