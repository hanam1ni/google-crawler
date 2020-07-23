defmodule GoogleCrawler.Keyword do
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
end
