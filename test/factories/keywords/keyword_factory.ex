defmodule GoogleCrawler.Keywords.KeywordFactory do
  alias GoogleCrawler.Keywords.Keyword

  defmacro __using__(_opts) do
    quote do
      def keyword_factory do
        %Keyword{
          title: Faker.Lorem.word(),
          result_page_html: nil,
          status: Keyword.statuses().initial,
          user: build(:user)
        }
      end

      def completed_scraped_keyword_factory do
        struct!(
          keyword_factory(),
          %{
            result_page_html: Faker.Lorem.paragraph(),
            status: Keyword.statuses().scrape_completed
          }
        )
      end
    end
  end
end
