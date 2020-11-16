defmodule GoogleCrawlerWeb.Plugs.Tests.MockOauth do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn = Plug.Conn.fetch_query_params(conn)
    email = Map.get(conn.query_params, "signin_as")

    assign(conn, :ueberauth_auth, build_auth_payload(email))
  end

  defp build_auth_payload(email) do
    %{
      credentials: %{
        token: "MOCK_TOKEN"
      },
      info: %{
        email: email
      }
    }
  end
end
