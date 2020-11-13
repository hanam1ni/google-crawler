defmodule GoogleCrawlerWeb.Api.AuthController do
  use GoogleCrawlerWeb, :controller

  plug Ueberauth

  alias GoogleCrawler.User
  alias GoogleCrawler.Repo

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, _user} ->
        conn
        |> put_status(:ok)
        |> render("token.json", %{})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
