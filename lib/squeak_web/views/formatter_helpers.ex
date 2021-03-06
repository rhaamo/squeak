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
    mdown =
      case mdown do
        nil -> ""
        _ -> mdown
      end

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
      Squeak.Namespaces.Namespace.get_by_name_and_parent_id("meta", nil)
      |> Squeak.Wiki.Page.get_in_namespace_query()
      |> Squeak.Repo.all()

    %{"root" => rootlesses, "meta" => metas}
  end

  def wiki_page_url(conn, name, namespaces) do
    path =
      (namespaces ++ [name])
      |> Enum.join(":")

    reencode(SqueakWeb.Router.Helpers.wiki_url(conn, :page, [path]))
  end

  def wiki_page_path(conn, name, namespaces, action \\ :page) do
    path =
      (namespaces ++ [name])
      |> Enum.join(":")

    reencode(SqueakWeb.Router.Helpers.wiki_path(conn, action, [path]))
  end

  def wiki_page_revision_path(conn, name, namespaces, action \\ :page, revision) do
    path =
      (namespaces ++ [name])
      |> Enum.join(":")

    reencode(SqueakWeb.Router.Helpers.wiki_path(conn, action, revision, [path]))
  end

  def wiki_edit_page_url(conn, fullpath, action \\ :edit) do
    path =
      fullpath
      |> Enum.join(":")

    reencode(SqueakWeb.Router.Helpers.wiki_edit_url(conn, action, [path]))
  end

  def namespaces_objs_to_list(page) do
    nses = Squeak.Wiki.Page.get_namespaces_from_page(page)
    Enum.map(nses, fn x -> x.name end)
  end

  def redact_serial_number(sn, current_user) do
    case current_user do
      nil -> "---"
      _ -> sn
    end
  end

  def is_active(conn, controller, action) do
    if conn.private.phoenix_controller == controller and conn.private.phoenix_action == action do
      true
    else
      false
    end
  end
end
