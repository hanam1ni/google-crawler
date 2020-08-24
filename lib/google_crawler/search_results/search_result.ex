defmodule GoogleCrawler.SearchResults.SearchResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_results" do
    field :url, :string
    field :title, :string
    field :is_ad, :boolean
    field :is_top_ad, :boolean

    belongs_to :keyword, GoogleCrawler.Keywords.Keyword

    timestamps()
  end

  @doc false
  def create_changeset(search_result \\ %__MODULE__{}, keyword, attrs) do
    search_result
    |> cast(attrs, [:url, :title, :is_ad, :is_top_ad])
    |> validate_required([:url, :title])
    |> Ecto.Changeset.put_assoc(:keyword, keyword)
  end
end
