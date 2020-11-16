defmodule GoogleCrawler.Repo.Migrations.AddUserReferenceToKeywords do
  use Ecto.Migration

  def change do
    alter table("keywords") do
      add(:user_id, references(:users, on_delete: :delete_all))
    end

    drop(unique_index("keywords", [:title]))
    create(unique_index("keywords", [:title, :user_id]))
  end
end
