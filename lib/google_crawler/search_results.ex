defmodule GoogleCrawler.SearchResults do
  alias GoogleCrawler.Repo
  alias GoogleCrawler.SearchResults.SearchResult

  @spec create_search_result(map()) ::
          {:ok, %SearchResult{} | {:error, Ecto.Changeset.t()}}
  def create_search_result(attrs) do
    SearchResult.create_changeset(attrs)
    |> Repo.insert()
  end
end
