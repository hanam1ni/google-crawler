defmodule GoogleCrawler.Keywords.KeywordImporter do
  @file_content_type "text/csv"
  @keyword_separator ?,

  alias GoogleCrawler.{Keywords, Repo}
  alias GoogleCrawler.Keywords.KeywordImportError

  def import(%{content_type: @file_content_type, path: keyword_path}, user_id) do
    csv_stream = decode_csv(keyword_path)

    Repo.transaction(fn -> do_import(csv_stream, user_id) end)
  end

  def import(_, _), do: {:error, "Invalid file type."}

  defp decode_csv(keyword_path) do
    keyword_path
    |> File.stream!()
    |> CSV.decode(separator: @keyword_separator)
  end

  defp do_import(csv_stream, user_id) do
    try do
      Enum.each(csv_stream, fn stream_row ->
        case stream_row do
          {:ok, keywords} ->
            Enum.each(keywords, fn keyword -> create_keyword(keyword, user_id) end)

          {:error, _} ->
            raise KeywordImportError
        end
      end)
    rescue
      e in KeywordImportError -> Repo.rollback(e.message)
    end
  end

  defp create_keyword(title, user_id) do
    case Keywords.create_keyword(%{title: title, user_id: user_id}) do
      {:ok, _} -> :ok
      {:error, _} -> raise KeywordImportError
    end
  end
end
