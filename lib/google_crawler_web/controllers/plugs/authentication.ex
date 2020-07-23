defmodule GoogleCrawlerWeb.Plugs.Authentication do
  import Plug.Conn
  import Phoenix.Controller

  alias GoogleCrawler.Repo
  alias GoogleCrawler.User

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user)

      true ->
        assign(conn, :user, nil)
    end
  end
end
