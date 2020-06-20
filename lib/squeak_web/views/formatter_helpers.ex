defmodule SqueakWeb.FormatterHelpers do
  use Timex
  import Phoenix.HTML

  def date_format_iso(date) do
    date_format(date, "{ISO:Extended:Z}")
  end

  def date_format(date, format_string \\ "{D} {Mshort} {YYYY}") do
    date
    |> Timex.format!(format_string)
  end

  def unmarkdownize_unsafe(mdown, lines \\ nil) do
    if is_nil(lines) do
      mdown
    else
      mdown
      |> String.split(["\n", "\r", "\r\n"])
      |> Enum.slice(0, lines)
    end
    |> Earmark.as_html!(gfm: true, breaks: false)
  end

  def unmarkdownize(mdown, lines \\ nil) do
    unmarkdownize_unsafe(mdown, lines)
    |> raw
  end

  def is_image(media) do
    String.starts_with?(media.mime, "image/")
  end

  def reencode(str), do: str |> URI.decode() |> URI.encode()

  # TODO: this doesn't handle a proper tree but only root-less and meta
  def wiki_tree() do
    rootlesses = Squeak.Wiki.Page.get_rootless_pages_query() |> Squeak.Repo.all()

    metas =
      Squeak.Namespaces.Namespace.get_by_name_and_parent("meta", nil)
      |> Squeak.Wiki.Page.get_in_namespace_query()
      |> Squeak.Repo.all()

    %{"root" => rootlesses, "meta" => metas}
  end

  def wiki_page_url(conn, name, namespaces) do
    ns = Enum.join(namespaces, ":")
    path = "#{ns}:#{name}"
    reencode(SqueakWeb.Router.Helpers.wiki_path(conn, :page, path))
  end
end
