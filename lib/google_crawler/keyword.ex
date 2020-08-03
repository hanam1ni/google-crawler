defmodule GoogleCrawler.Keyword do
  use Ecto.Schema
  
  import Ecto.Changeset
  import Ecto.Query

  @statuses %{
    initial: "initial",
    scraping: "scraping",
    scrape_completed: "scrape_completed",
    scrape_failed: "scrape_failed",
    parsing: "parsing",
    parse_completed: "parse_completed",
    parse_failed: "parse_failed"
  }

  schema "keywords" do
    field :title, :string
    field :result_page_html, :string
    field :status, :string, default: @statuses.initial

    # Result report
    field :result_count, :integer, virtual: true
    field :ad_count, :integer, virtual: true
    field :top_ad_count, :integer, virtual: true

    has_many :search_results, GoogleCrawler.SearchResult

    timestamps()
  end

  @doc false
  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:title, :result_page_html])
    |> validate_required([:title])
    |> unique_constraint(:title)
    |> validate_inclusion(:status, Map.values(@statuses))
  end

  def statuses do
    @statuses
  end

  def with_result_report(keyword_query) do
    keyword_query
    |> join(:left, [keyword], search_results in assoc(keyword, :search_results))
    |> group_by([keyword], keyword.id)
    |> select_merge([_, search_results], %{
      result_count: count(search_results.id),
      ad_count: fragment("sum(?::int)", search_results.is_ad),
      top_ad_count: fragment("sum(?::int)", search_results.is_top_ad)
    })
  end
end
