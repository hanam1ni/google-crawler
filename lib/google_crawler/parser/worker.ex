defmodule GoogleCrawler.Parser.Worker do
  use GenServer, restart: :transient

  alias GoogleCrawler.Keyword
  alias GoogleCrawler.SearchResult
  alias GoogleCrawler.Repo

  @top_ad_selector "#taw .ads-ad a"
  @ad_selector "#bottomads .ads-ad a"
  @result_selector "#search .rc a"

  # Client Interface
  def start_link(keyword) do
    GenServer.start_link(__MODULE__, {keyword})
  end

  # Server
  def init(state) do
    GenServer.cast(self(), {:generate})

    {:ok, state}
  end

  def handle_cast({:generate}, {keyword}) do
    parse(keyword)
    |> save_result(keyword)

    mark_as_completed(keyword)

    {:noreply, {keyword}}
  end

  defp save_result(result_params, keyword) do
    Enum.map(result_params, fn params ->
      %SearchResult{}
      |> SearchResult.changeset(params)
      |> Ecto.Changeset.put_assoc(:keyword, keyword)
      |> Repo.insert()
    end)
  end

  defp parse(keyword) do
    Floki.parse_document(keyword.result_page_html)
    |> case do
      {:ok, document} ->
        result_to_params([], document, @top_ad_selector, %{is_ad: true, is_top_ad: true})
        |> result_to_params(document, @ad_selector, %{is_ad: true})
        |> result_to_params(document, @result_selector)
    end
  end

  defp result_to_params(params, document, selector, optional_params \\ %{}) do
    document
    |> find_element_by(selector)
    |> build_params(optional_params)
    |> Enum.concat(params)
  end

  defp find_element_by(document, selector) do
    document
    |> Floki.find(selector)
    |> filter_valid_result
  end

  defp filter_valid_result(document) do
    document
    |> Enum.filter(fn {_tag, _attributes, child_node} -> Floki.find(child_node, "h3") != [] end)
  end

  defp build_params(document, optional_params) do
    Enum.map(document, fn {_tag, attributes, child_node} ->
      {_property, result_url} = Enum.find(attributes, fn {property, _} -> property == "href" end)

      {_tag, _attributes, [title | _]} = Enum.find(child_node, fn {tag, _, _} -> tag == "h3" end)

      Map.merge(%{url: result_url, title: title}, optional_params)
    end)
  end

  defp mark_as_completed(keyword) do
    keyword
    |> Ecto.Changeset.change(status: Keyword.statuses().parse_completed)
    |> Repo.update!()
  end
end
