defmodule GoogleCrawlerWeb.ViewCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.View
      import GoogleCrawler.Factory
    end
  end
end
