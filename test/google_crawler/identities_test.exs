defmodule GoogleCrawler.IdentitiesTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.Identities

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
end
