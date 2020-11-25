defmodule GoogleCrawlerWeb.ViewCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Mimic

      import Phoenix.View
      import GoogleCrawler.Factory
    end
  end
end
