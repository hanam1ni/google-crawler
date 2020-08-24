defmodule GoogleCrawlerWeb.KeywordView do
  use GoogleCrawlerWeb, :view

  def formatted_status(status) do
    status
    |> String.capitalize()
    |> String.replace("_", " ")
  end

  def formatted_result_count(count) do
    if count do
      count
    else
      "-"
    end
  end
end
