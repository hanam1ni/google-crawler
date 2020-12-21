defmodule GoogleCrawler.Keywords do
  import Ecto.Query

  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.Keywords.ScraperSupervisor
  alias GoogleCrawler.Repo

  @scraped_keywords_per_chunk 10

  def create_keyword(attrs) do
    Keyword.create_changeset(attrs)
    |> Repo.insert()
  end

  def delete_keyword(%Keyword{} = keyword) do
    Repo.delete(keyword)
  end

  def list_keywords(user_id, filter_params) do
    compacted_params = compact_params(filter_params)

    subquery(
      keyword_with_result_report()
      |> where(user_id: ^user_id)
      |> filter_by_url(compacted_params)
      |> order_by([:id])
    )
    |> filter_by_title(compacted_params)
    |> filter_by_result_count(compacted_params)
    |> Repo.all()
  end

  def get_keyword_for_user(user_id, id) do
    keyword_with_result_report()
    |> preload([:search_results])
    |> Repo.get_by(id: id, user_id: user_id)
  end

  def scrape_keyword do
    keywords_with_initial_status()
    |> Enum.chunk_every(@scraped_keywords_per_chunk)
    |> Enum.each(fn keyword_set -> ScraperSupervisor.start_child(keyword_set) end)
  end

  def update_keyword_result(keyword, result_page_html) do
    keyword
    |> Keyword.update_result_page_html_changeset(result_page_html)
    |> Keyword.update_status_changeset(Keyword.statuses().scrape_completed)
    |> Repo.update()
  end

  def update_keyword_status(keyword, status) do
    keyword
    |> Keyword.update_status_changeset(status)
    |> Repo.update()
    |> case do
      {:ok, keyword} -> keyword
    end
  end

  defp keywords_with_initial_status do
    Keyword
    |> where(status: ^Keyword.statuses().initial)
    |> Repo.all()
  end

  defp keyword_with_result_report do
    Keyword
    |> join(:left, [keyword], search_results in assoc(keyword, :search_results),
      as: :search_results
    )
    |> group_by([keyword], keyword.id)
    |> select_merge([search_results: sr], %{
      result_count: count(sr.id),
      ad_count: fragment("sum(?::int)", sr.is_ad),
      top_ad_count: fragment("sum(?::int)", sr.is_top_ad)
    })
  end

  defp compact_params(nil), do: nil

  defp compact_params(params) do
    params
    |> Enum.filter(fn {_key, value} -> value !== "" end)
    |> Enum.into(%{})
  end

  defp filter_by_title(keywords, %{"title" => title}) do
    keywords
    |> where([k], fragment("? LIKE ?", k.title, ^"%#{title}%"))
  end

  defp filter_by_title(keywords, _), do: keywords

  defp filter_by_url(keywords, %{"url" => url}) do
    keywords
    |> where([search_results: sr], fragment("? LIKE ?", sr.url, ^"%#{url}%"))
  end

  defp filter_by_url(keywords, _), do: keywords

  defp filter_by_result_count(keywords, %{
         "result_count_operation" => result_count_operation,
         "result_count_value" => result_count_value
       }) do
    {value, _} = Integer.parse(result_count_value)

    case result_count_operation do
      ">" -> where(keywords, [k], fragment("? > ?", k.result_count, ^value))
      "<" -> where(keywords, [k], fragment("? < ?", k.result_count, ^value))
      "=" -> where(keywords, [k], fragment("? = ?", k.result_count, ^value))
      _ -> keywords
    end
  end

  defp filter_by_result_count(keywords, _), do: keywords
end
