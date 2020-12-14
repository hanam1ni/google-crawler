defmodule GoogleCrawler.TokenizerTest do
  use GoogleCrawler.DataCase, async: true

  alias GoogleCrawler.Tokenizer

  describe "generate_access_token/1" do
    test "generates valid access token for the given user" do
      user = insert(:user)

      assert {:ok, access_token, _option} = Tokenizer.generate_access_token(user)

      assert {:ok, claims} = Tokenizer.decode_and_verify(access_token)
      assert claims["sub"] == user.id
      assert claims["typ"] == "access"
    end
  end

  describe "subject_for_token/2" do
    test "returns resource id for the given resource" do
      user = insert(:user)

      assert Tokenizer.subject_for_token(user, %{}) == {:ok, user.id}
    end
  end

  describe "resource_from_claims/1" do
    test "returns {:ok, user} when found the user" do
      user = insert(:user)
      claims = %{"sub" => user.id}

      assert Tokenizer.resource_from_claims(claims) == {:ok, user}
    end

    test "returns {:error, :user_not_found} when the user not found" do
      claims = %{"sub" => 999}

      assert Tokenizer.resource_from_claims(claims) == {:error, :user_not_found}
    end
  end
end
