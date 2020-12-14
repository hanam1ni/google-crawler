defmodule GoogleCrawler.IdentitiesTest do
  use GoogleCrawler.DataCase, async: true

  alias GoogleCrawler.Identities
  alias GoogleCrawler.Identities.User

  describe "get_user_by/1" do
    test "returns user when found user with the given params" do
      user1 = insert(:user, email: "user1@mail.com")
      _user2 = insert(:user, email: "user2@mail.com")

      user_from_db = Identities.get_user_by(email: "user1@mail.com")

      assert user_from_db.id == user1.id
      assert user_from_db.email == user1.email
    end

    test "returns nil when user not found" do
      _user = insert(:user, email: "user@mail.com")

      assert nil == Identities.get_user_by(email: "other_user@mail.com")
    end
  end

  describe "create_user/1" do
    test "creates user if given valid params" do
      attrs = %{
        email: "user@email.com",
        provider: "google",
        token: "TOKEN_1234"
      }

      _created_user = Identities.create_user(attrs)

      [user_in_db] = Repo.all(User)
      assert user_in_db.email == "user@email.com"
      assert user_in_db.provider == "google"
      assert user_in_db.token == "TOKEN_1234"
    end

    test "returns invalid changeset if given invalid params" do
      attrs = %{
        email: "",
        provider: "google",
        token: "TOKEN_1234"
      }

      {:error, changeset} = Identities.create_user(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["can't be blank"]
             }
    end
  end
end
