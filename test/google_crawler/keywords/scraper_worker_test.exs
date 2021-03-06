defmodule GoogleCrawler.Keywords.ScraperWorkerTest do
  use GoogleCrawler.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup :set_mimic_global

  alias GoogleCrawler.Keywords.Keyword
  alias GoogleCrawler.Keywords.ScraperWorker
  alias GoogleCrawler.Repo

  describe "start_link/1" do
    test "updates the given keywords result_page_html" do
      use_cassette "fetch_keyword_result" do
        keyword = insert(:keyword, title: "hosting")

        GoogleCrawler.SearchResults.ParserSupervisor
        |> expect(:start_child, fn %Keyword{title: "hosting"} = keyword -> keyword end)

        assert {:ok, worker_pid} = ScraperWorker.start_link([keyword])
        ensure_worker_stop(worker_pid)

        keyword = Repo.get(Keyword, keyword.id)
        assert keyword.status == Keyword.statuses().scrape_completed
      end
    end
  end

  defp ensure_worker_stop(pid) do
    ref = Process.monitor(pid)
    GenServer.stop(pid, :normal)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
