defmodule GoogleCrawler.SearchResults do
  alias GoogleCrawler.Repo
  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.SearchResults.SearchResult

  @spec create_search_result(%Keyword{}, map()) :: {:ok, %SearchResult{} | {:error, Ecto.Changeset.t()}}
  def create_search_result(%Keyword{} = keyword, attr) do
    SearchResult.create_changeset(keyword, attr)
    |> Repo.insert()
  end
end
