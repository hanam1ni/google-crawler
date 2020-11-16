defmodule GoogleCrawler.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :text)
      add(:provider, :text)
      add(:token, :text)

      timestamps()
    end

    create(unique_index("users", [:email]))
  end
end
