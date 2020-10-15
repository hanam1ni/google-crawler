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

  def delete_keyword(id) do
    Repo.get!(Keyword, id)
    |> Repo.delete()
  end

  def list_keywords(user_id, filter_params) do
    keyword_with_result_report()
    |> filter_by_url(filter_params)
    |> where(user_id: ^user_id)
    |> order_by([:id])
    |> Repo.all()
  end

  def get_keyword_by_id(id) do
    keyword_with_result_report()
    |> preload([:search_results])
    |> Repo.get(id)
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
    |> join(:left, [keyword], search_results in assoc(keyword, :search_results), as: :search_results)
    |> group_by([keyword], keyword.id)
    |> select_merge([search_results: sr], %{
      result_count: count(sr.id),
      ad_count: fragment("sum(?::int)", sr.is_ad),
      top_ad_count: fragment("sum(?::int)", sr.is_top_ad)
    })
  end

  defp filter_by_url(keywords, %{"url" => url}) do
    keywords
    |> where([search_results: sr], fragment("? LIKE ?", sr.url, ^"%#{url}%"))
  end

  defp filter_by_url(keywords, _), do: keywords
end
