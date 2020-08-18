defmodule GoogleCrawler.Scraper.SupervisorTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.Scraper.Supervisor

  describe "start_child/1" do
    test "starts the scraping worker" do
      keywords = insert_list(2, :keyword)

      assert {:ok, worker_pid} = Supervisor.start_child(keywords)
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
