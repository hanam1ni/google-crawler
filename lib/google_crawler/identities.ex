defmodule GoogleCrawler.Identities do
  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.Repo

  def get_user_by(params) do
    Repo.get_by(User, params)
  end
end
