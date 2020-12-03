defmodule GoogleCrawlerWeb.Api.AuthController do
  use GoogleCrawlerWeb, :controller

  plug Ueberauth

  alias GoogleCrawler.{Identities, Tokenizer}
  alias GoogleCrawlerWeb.ErrorHandler

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}

    signin(conn, user_params)
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        {:ok, access_token, _} = Tokenizer.generate_access_token(user)

        conn
        |> put_status(:ok)
        |> render("token.json", %{access_token: access_token})

      {:error, _} ->
        conn
        |> ErrorHandler.handle(:bad_request)
    end
  end

  defp insert_or_update_user(user_params) do
    case Identities.get_user_by(%{email: user_params.email}) do
      nil ->
        Identities.create_user(user_params)

      user ->
        {:ok, user}
    end
  end
end
