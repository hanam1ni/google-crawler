defmodule GoogleCrawler.SearchResults.ParserSupervisor do
  use DynamicSupervisor

  alias GoogleCrawler.SearchResults.ParserWorker

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(keyword) do
    child_spec = {ParserWorker, keyword}

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
