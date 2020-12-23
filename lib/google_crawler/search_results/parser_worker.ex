defmodule GoogleCrawler.SearchResults.ParserWorker do
  use GenServer, restart: :transient

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.Keyword, as: GoogleKeyword
  alias GoogleCrawler.SearchResults

  @top_ad_selector %{item: "#taw .d5oMvf a", title: ".cfxYMc"}
  @bottom_ad_selector %{item: "#bottomads .d5oMvf a", title: ".cfxYMc"}
  @result_selector %{item: ".yuRUbf a", title: ".LC20lb span"}
  @url_property "href"

  # Client Interface
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(keyword) do
    GenServer.start_link(__MODULE__, {keyword})
  end

  # Server
  def init(state) do
    GenServer.cast(self(), {:parsing})

    {:ok, state}
  end

  def handle_cast({:parsing}, {keyword}) do
    keyword
    |> Keywords.update_keyword_status(GoogleKeyword.statuses().parsing)
    |> parse_result_page
    |> case do
      {:ok, result_params} ->
        save_result(result_params, keyword.id)
        Keywords.update_keyword_status(keyword, GoogleKeyword.statuses().parse_completed)

      {:error} ->
        Keywords.update_keyword_status(keyword, GoogleKeyword.statuses().parse_failed)
    end

    {:noreply, {keyword}}
  end

  defp save_result(result_params, keyword_id) do
    Enum.each(result_params, fn params ->
      params
      |> Map.put(:keyword_id, keyword_id)
      |> SearchResults.create_search_result()
    end)
  end

  defp parse_result_page(keyword) do
    Floki.parse_document(keyword.result_page_html)
    |> case do
      {:ok, document} ->
        result_params =
          build_result_params(document, @top_ad_selector, %{is_ad: true, is_top_ad: true})
          |> Enum.concat(build_result_params(document, @bottom_ad_selector, %{is_ad: true}))
          |> Enum.concat(build_result_params(document, @result_selector))

        {:ok, result_params}

      _ ->
        {:error}
    end
  end

  defp build_result_params(document, selector, optional_params \\ %{}) do
    document
    |> Floki.find(selector.item)
    |> Enum.map(fn {_, _, child_nodes} = result_item ->
      [url] = Floki.attribute(result_item, @url_property)

      title =
        child_nodes
        |> Floki.find(selector.title)
        |> Floki.text()

      Map.merge(%{url: url, title: title}, optional_params)
    end)
  end
end
