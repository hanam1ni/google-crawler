defmodule GoogleCrawler.Identities do
  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.Repo

  def get_user_by(params) do
    User
    |> Repo.get_by(params)
  end
end
