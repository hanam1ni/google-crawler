defmodule GoogleCrawler.Keywords.ScraperSupervisorTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.Keywords.ScraperSupervisor
  alias GoogleCrawler.SearchResults.ParserSupervisor

  describe "start_child/1" do
    test "starts the scraping worker" do
      keywords = insert_list(2, :keyword)

      ParserSupervisor
      |> stub(:start_child, fn keyword -> keyword end)

      assert {:ok, worker_pid} = ScraperSupervisor.start_child(keywords)
      assert is_pid(worker_pid)

      ensure_worker_stop(worker_pid)
    end
  end

  defp ensure_worker_stop(pid) do
    ref = Process.monitor(pid)
    GenServer.stop(pid, :normal)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
