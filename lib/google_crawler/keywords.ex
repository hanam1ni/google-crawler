defmodule GoogleCrawler.Keywords do
  import Ecto.Query

  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.Keywords.ScraperSupervisor
  alias GoogleCrawler.Repo
  alias GoogleCrawler.User

  @scraped_keywords_per_chunk 10

  def create_keyword(%User{} = user, attrs) do
    user
    |> Ecto.build_assoc(:keywords)
    |> Keyword.create_changeset(attrs)
    |> Repo.insert()
  end

  def delete_keyword(id) do
    Repo.get(Keyword, id)
    |> Repo.delete
  end

  def list_keywords(user_id) do
    keywords_with_result_report()
    |> where(user_id: ^user_id)
    |> order_by([:id])
    |> Repo.all()
  end

  def get_keyword_by_id(id) do
    keywords_with_result_report()
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
    |> where(status: ^Keyword.statuses.initial)
    |> Repo.all()
  end

  defp keywords_with_result_report do
    Keyword
    |> join(:left, [keyword], search_results in assoc(keyword, :search_results))
    |> group_by([keyword], keyword.id)
    |> select_merge([_, search_results], %{
      result_count: count(search_results.id),
      ad_count: fragment("sum(?::int)", search_results.is_ad),
      top_ad_count: fragment("sum(?::int)", search_results.is_top_ad)
    })
  end
end
