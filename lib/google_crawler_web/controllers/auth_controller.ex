defmodule GoogleCrawlerWeb.AuthController do
  use GoogleCrawlerWeb, :controller

  plug Ueberauth

  alias GoogleCrawler.Identities.User
  alias GoogleCrawler.Repo

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}
    changeset = User.changeset(%User{}, user_params)

    sign_in(conn, changeset)
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Successfully signed out")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp sign_in(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome #{user.email}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: Routes.keyword_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong, please try again")
        |> redirect(to: Routes.keyword_path(conn, :index))
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
