defmodule GoogleCrawlerWeb.KeywordViewTest do
  use GoogleCrawlerWeb.ViewCase, async: true

  alias GoogleCrawlerWeb.KeywordView

  describe "operation_selected?/2" do
    test "returns 'selected' if given selected operator match the operator" do
      assert "selected" == KeywordView.operation_selected?(">", ">")
    end

    test "returns empty string if given selected operator does not match the operator" do
      assert "" == KeywordView.operation_selected?(">", "=")
    end
  end

  describe "formatted_status/1" do
    test "returns formatted status" do
      assert "Parse completed" == KeywordView.formatted_status("parse_completed")
    end
  end

  describe "formatted_result_count/1" do
    test "returns count if given valid count" do
      assert 10 == KeywordView.formatted_result_count(10)
    end

    test "returns - if given nil in count" do
      assert "-" == KeywordView.formatted_result_count(nil)
    end
  end
end
