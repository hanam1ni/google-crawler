defmodule GoogleCrawler.SearchResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_results" do
    field :url, :string
    field :title, :string
    field :is_ad, :boolean
    field :is_top_ad, :boolean

    belongs_to :keyword, GoogleCrawler.Keyword

    timestamps()
  end

  @doc false
  def changeset(search_result, attrs) do
    search_result
    |> cast(attrs, [:url, :title, :is_ad, :is_top_ad])
    |> validate_required([:url, :title])
  end
end
