defmodule GoogleCrawler.SearchResultFactory do  
  alias GoogleCrawler.SearchResult

  defmacro __using__(_opts) do
    quote do
      def search_result_factory do
        %SearchResult{
          url: Faker.Internet.domain_name,
          title: Faker.Lorem.word,
          is_ad: false,
          is_top_ad: false
        }
      end

      def ad_search_result_factory do
        struct!(
          search_result_factory(),
          %{
            is_ad: true,
            is_top_ad: false
          }
        )
      end

      def top_ad_search_result_factory do
        struct!(
          search_result_factory(),
          %{
            is_ad: true,
            is_top_ad: true
          }
        )
      end
    end
  end
end