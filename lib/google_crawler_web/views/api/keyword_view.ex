defmodule GoogleCrawlerWeb.Api.KeywordView do
  use GoogleCrawlerWeb, :view

  def fields, do: [:title, :status]
  def type, do: "keyword"
end
