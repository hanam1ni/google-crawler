defmodule GoogleCrawler.Scraper.Worker do
  use GenServer, restart: :transient

  alias GoogleCrawler.Repo
  alias GoogleCrawler.Keyword

  @delay_interval 100
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"
  @base_url "https://www.google.com/search?q="

  # Client Interface
  def start_link(keywords) do
    GenServer.start_link(__MODULE__, {keywords})
  end

  # Server
  def init(state) do
    GenServer.cast(self(), {:scrape})

    {:ok, state}
  end

  def handle_cast({:scrape}, {keywords}) do
    Enum.each(keywords, fn keyword ->
      keyword
      |> mark_as_scraping
      |> fetch_result
      |> case do
        {:ok, body} ->
          keyword
          |> Ecto.Changeset.change(result_page_html: body)
          |> Repo.update!()
          |> mark_as_completed
      end

      :timer.sleep(@delay_interval)
    end)

    {:noreply, {keywords}}
  end

  defp fetch_result(keyword) do
    encoded_title =
      keyword.title
      |> URI.encode()

    headers = ["user-agent": @user_agent]

    HTTPoison.start()
    HTTPoison.get("#{@base_url}#{encoded_title}", headers)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
    end
  end

  defp mark_as_scraping(keyword) do
    keyword
    |> Ecto.Changeset.change(status: Keyword.statuses().scraping)
    |> Repo.update!()
  end

  defp mark_as_completed(keyword) do
    keyword
    |> Ecto.Changeset.change(status: Keyword.statuses().scrape_completed)
    |> Repo.update!()
  end
end
