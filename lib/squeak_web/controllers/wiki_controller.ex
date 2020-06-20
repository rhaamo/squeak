defmodule SqueakWeb.WikiController do
  use SqueakWeb, :controller

  defp split_path(path) do
    fullpath = Enum.reverse(String.split(path, ":"))
    page = hd(fullpath)
    namespaces = tl(fullpath)
    namespaces = namespaces |> Enum.reverse()
    [namespaces, page]
  end

  def page(conn, %{"path" => path}) do
    [namespaces, page_name] = split_path(path)
    # todo handle parent_id for namespace
    namespace = Squeak.Namespaces.Namespace.get_by_name_and_parent(List.last(namespaces), nil)
    page = Squeak.Wiki.Page.get_by_namespace_and_name(namespace, page_name)

    if is_nil(page) do
      render(conn, "not_found.html",
        namespaces: namespaces,
        path: namespaces ++ [page_name],
        page: page
      )
    else
      render(conn, "page.html",
        namespaces: namespaces,
        path: namespaces ++ [page_name],
        page: page
      )
    end
  end
end
