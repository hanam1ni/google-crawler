defmodule GoogleCrawlerWeb.Api.AuthController do
  use GoogleCrawlerWeb, :controller

  plug Ueberauth

  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.{Repo, Tokenizer}
  alias GoogleCrawlerWeb.ErrorHandler

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
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

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email, token: changeset.changes.token) do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
