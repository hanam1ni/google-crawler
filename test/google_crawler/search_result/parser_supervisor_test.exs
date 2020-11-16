defmodule GoogleCrawler.SearchResults.ParserSupervisorTest do
  use GoogleCrawler.DataCase

  alias GoogleCrawler.SearchResults.ParserSupervisor

  describe "start_child/1" do
    test "starts the parsing worker" do
      keyword = insert(:completed_scraped_keyword)

      assert {:ok, worker_pid} = ParserSupervisor.start_child(keyword)
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
