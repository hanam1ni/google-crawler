defmodule GoogleCrawler.Repo.Migrations.CreateKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :title, :text
      add :result_page_html, :text
      add :status, :string

      timestamps()
    end

    create unique_index("keywords", [:title])
  end
end
