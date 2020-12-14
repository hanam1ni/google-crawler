defmodule GoogleCrawler.Tokenizer do
  use Guardian, otp_app: :google_crawler

  alias GoogleCrawler.Identities

  def generate_access_token(user) do
    encode_and_sign(user, %{}, ttl: {7, :days})
  end

  def subject_for_token(resource, _options) do
    {:ok, resource.id}
  end

  def resource_from_claims(claims) do
    Identities.get_user_by(id: claims["sub"])
    |> case do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
