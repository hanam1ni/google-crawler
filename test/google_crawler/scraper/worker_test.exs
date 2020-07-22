defmodule GoogleCrawler.WorkerTest do
  use GoogleCrawler.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias GoogleCrawler.Keyword
  alias GoogleCrawler.Repo
  alias GoogleCrawler.Scraper.Worker

  describe "start_link/1" do
    test "updates the given keywords result_page_html" do
      use_cassette "fetch_keyword_result" do
        keyword = insert(:keyword, title: "apple")
        
        assert {:ok, worker_pid} = Worker.start_link([keyword])

        ensure_worker_stop(worker_pid)

        keyword = Repo.get(Keyword, keyword.id)
        assert keyword.status == Keyword.statuses.scrape_completed
      end
    end
  end

  defp ensure_worker_stop(pid) do
    ref = Process.monitor(pid)
    GenServer.stop(pid, :normal)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end