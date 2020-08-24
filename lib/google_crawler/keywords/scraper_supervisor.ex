defmodule GoogleCrawler.Keywords.ScraperSupervisor do
  use DynamicSupervisor

  alias GoogleCrawler.Keywords.ScraperWorker

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(keywords) do
    child_spec = {ScraperWorker, keywords}

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
