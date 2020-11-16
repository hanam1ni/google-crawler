defmodule GoogleCrawler.SearchResults.ParserWorker do
  use GenServer, restart: :transient

  alias GoogleCrawler.Keywords
  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.SearchResults

  @top_ad_selector "#taw .ads-fr a"
  @ad_selector "#bottomads .ads-fr a"
  @result_selector "#search .rc a"
  @result_title_selector ["h3", "div"]
  @result_url_property "href"

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
    |> Keywords.update_keyword_status(Keyword.statuses().parsing)
    |> parse_result_page
    |> case do
      {:ok, result_params} ->
        save_result(result_params, keyword)
        Keywords.update_keyword_status(keyword, Keyword.statuses().parse_completed)

      {:error} ->
        Keywords.update_keyword_status(keyword, Keyword.statuses().parse_failed)
    end

    {:noreply, {keyword}}
  end

  defp save_result(result_params, keyword) do
    Enum.each(result_params, fn params ->
      params
      |> Map.put(:keyword_id, keyword.id)
      |> SearchResults.create_search_result()
    end)
  end

  defp parse_result_page(keyword) do
    Floki.parse_document(keyword.result_page_html)
    |> case do
      {:ok, document} ->
        result_params =
          result_to_params([], document, @top_ad_selector, %{is_ad: true, is_top_ad: true})
          |> result_to_params(document, @ad_selector, %{is_ad: true})
          |> result_to_params(document, @result_selector)

        {:ok, result_params}

      _ ->
        {:error}
    end
  end

  defp result_to_params(params, document, selector, optional_params \\ %{}) do
    document
    |> find_element_by(selector)
    |> filter_valid_result
    |> build_params(optional_params)
    |> Enum.concat(params)
  end

  defp find_element_by(document, selector) do
    document
    |> Floki.find(selector)
  end

  defp filter_valid_result(document) do
    document
    |> Enum.filter(fn {_tag, _attributes, child_node} ->
      Floki.find(child_node, Enum.join(@result_title_selector, ",")) != []
    end)
  end

  defp build_params(document, optional_params) do
    document
    |> Enum.map(fn {_tag, attributes, child_node} ->
      {_property, result_url} =
        Enum.find(attributes, fn {property, _} -> property == @result_url_property end)

      {_tag, _attributes, [title | _]} =
        Enum.find(child_node, fn {tag, _, _} -> Enum.member?(@result_title_selector, tag) end)

      Map.merge(%{url: result_url, title: title}, optional_params)
    end)
  end
end
