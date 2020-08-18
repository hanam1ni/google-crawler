defmodule GoogleCrawler.Keywords.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

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

    belongs_to :user, GoogleCrawler.User
    has_many :search_results, GoogleCrawler.SearchResults.SearchResult

    timestamps()
  end

  @doc false
  def create_changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint([:title, :user_id])
  end

  def update_result_page_html_changeset(keyword, result_page_html) do
    keyword
    |> change(result_page_html: result_page_html)
  end

  def update_status_changeset(keyword, status) do
    keyword
    |> change(status: status)
    |> validate_inclusion(:status, Map.values(@statuses))
  end

  def statuses do
    @statuses
  end
end
