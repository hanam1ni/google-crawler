defmodule GoogleCrawler.UserFactory do
  alias GoogleCrawler.Identities.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          email: Faker.Internet.email(),
          provider: "google",
          token: Faker.UUID.v4()
        }
      end
    end
  end
end
