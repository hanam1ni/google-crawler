defmodule GoogleCrawlerWeb.KeywordView do
  use GoogleCrawlerWeb, :view

  def operation_selected?(selected_operator, operator) do
    if selected_operator == operator do
      "selected"
    else
      ""
    end
  end

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
