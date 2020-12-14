defmodule GoogleCrawlerWeb.Plugs.ApiAuthentication do
  import Plug.Conn

  alias GoogleCrawler.Identities.User
  alias GoogleCrawlerWeb.ErrorHandler

  def init(default), do: default

  def call(conn, _default) do
    case Guardian.Plug.current_resource(conn) do
      %User{} = user ->
        assign(conn, :user, user)

      _ ->
        conn
        |> ErrorHandler.handle(:unauthorized)
    end
  end
end
