defmodule GoogleCrawler.Repo.Migrations.CreateSearchResults do
  use Ecto.Migration

  def change do
    create table(:search_results) do
      add :url, :text
      add :title, :text
      add :is_ad, :boolean, default: false
      add :is_top_ad, :boolean, default: false

      add :keyword_id, references(:keywords, on_delete: :delete_all)

      timestamps()
    end
  end
end
