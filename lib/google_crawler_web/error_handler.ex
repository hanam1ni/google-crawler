defmodule GoogleCrawlerWeb.ErrorHandler do
  use Phoenix.Controller

  alias Ecto.Changeset
  alias GoogleCrawlerWeb.ErrorView

  def handle(conn, status) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", status: status)
    |> halt()
  end

  def handle(conn, status, %Changeset{} = changeset) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", status: status, changeset: changeset)
    |> halt()
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> handle(:forbidden)
  end

  def full_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {attribute, message} ->
      formatted_attribute = Phoenix.Naming.humanize(attribute)

      "#{formatted_attribute} #{message}"
    end)
    |> Enum.join(", ")
  end
end
