defmodule GoogleCrawler.SearchResults.ParserWorkerTest do
  use GoogleCrawler.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.SearchResults.{ParserWorker, SearchResult}
  alias GoogleCrawler.Repo

  describe "start_link/1" do
    test "creates the search result records for given keyword" do
      {:ok, response} = File.read("test/support/fixtures/vcr_cassettes/fetch_keyword_result.json")
      [%{"response" => %{"body" => result_html_body}}] = Poison.decode!(response)

      keyword = insert(:completed_scraped_keyword, result_page_html: result_html_body)

      assert {:ok, worker_pid} = ParserWorker.start_link(keyword)
      ensure_worker_stop(worker_pid)

      keyword = Repo.get(Keyword, keyword.id)
      search_result = Repo.all(SearchResult)

      assert length(search_result) == 10
      assert keyword.status == Keyword.statuses().parse_completed
    end
  end

  defp ensure_worker_stop(pid) do
    ref = Process.monitor(pid)
    GenServer.stop(pid, :normal)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
