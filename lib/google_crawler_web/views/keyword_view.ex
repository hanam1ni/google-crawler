defmodule GoogleCrawlerWeb.KeywordView do
  use GoogleCrawlerWeb, :view

  def formatted_status(status) do
    status
    |> String.capitalize
    |> String.replace("_", " ")
  end
end
