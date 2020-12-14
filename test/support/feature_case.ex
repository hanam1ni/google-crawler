defmodule GoogleCrawlerWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import Wallaby.Query
      import GoogleCrawler.Factory

      alias GoogleCrawlerWeb.Router.Helpers, as: Routes

      def login_as(session, %{email: email}) do
        session
        |> visit("/auth/test_provider/callback?sign_in_as=#{email}")
      end
    end
  end
end
