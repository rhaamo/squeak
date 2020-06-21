defmodule SqueakWeb.Plugs.WikiPath do
  use SqueakWeb, :controller

  def init(default), do: default

  @doc "Handle the splitting of path, and slug+downcasing"
  def call(%{params: %{"path" => path}} = conn, _) do
    [namespaces, page_name] = Squeak.Wiki.Page.split_path(path)

    namespaces_slugged =
      Enum.map(namespaces, fn p ->
        Slugger.slugify_downcase(p)
      end)

    page_name_slugged = Slugger.slugify_downcase(page_name)

    if [namespaces, page_name] != [namespaces_slugged, page_name_slugged] do
      url = SqueakWeb.FormatterHelpers.wiki_page_url(conn, page_name_slugged, namespaces_slugged)

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
