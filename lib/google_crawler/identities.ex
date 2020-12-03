defmodule GoogleCrawler.Identities do
  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.Repo

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def create_user(attrs) do
    Repo.insert(User.changeset(attrs))
  end
end
