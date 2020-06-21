defmodule SqueakWeb.Plugs.WikiPath do
  use SqueakWeb, :controller

  def init(default), do: default

  @doc "Handle the splitting of path, and slug+downcasing"
  def call(%{params: %{"path" => orig_path}} = conn, _) do
    path = orig_path |> Enum.join(":")
    [namespaces, page_name] = Squeak.Wiki.Page.split_path(path)

    namespaces_slugged =
      Enum.map(namespaces, fn p ->
        Slugger.slugify_downcase(p)
      end)

    page_name_slugged = Slugger.slugify_downcase(page_name)

    new_path = Enum.join(namespaces_slugged ++ [page_name_slugged], ":")

    # Notes: the routing is a glob, not classic arg, then "foo/bar" gets paramed as ["foo", "bar"]
    if Enum.join(orig_path, "/") != new_path do
      url =
        SqueakWeb.Router.Helpers.wiki_path(conn, :page, [new_path])
        |> SqueakWeb.FormatterHelpers.reencode()

      conn
      |> redirect(to: url)
    else
      conn
      |> assign(:page_name, page_name)
      |> assign(:namespaces, namespaces)
      |> assign(:fullpath, namespaces_slugged ++ [page_name_slugged])
    end
  end

  @doc "Last, handle /wiki/p"
  def call(%{params: %{}} = conn, _), do: conn
end
