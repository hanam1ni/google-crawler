defmodule GoogleCrawler.UserTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.User

  describe "changeset/2" do
    test "returns valid changeset when given valid attributes" do
      attrs = %{email: "user@email.com", provider: "google", token: "user_token"}

      changeset = User.changeset(attrs)

      assert changeset.valid?
      assert changeset.changes.email == "user@email.com"
      assert changeset.changes.provider == "google"
      assert changeset.changes.token == "user_token"
    end

    test "returns invalid changeset when required attributes are missing" do
      changeset = User.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["can't be blank"],
               provider: ["can't be blank"],
               token: ["can't be blank"]
             }
    end
  end
end
