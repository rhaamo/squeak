defmodule SqueakWeb.WikiController do
  use SqueakWeb, :controller
  require Logger

  defp split_path(path) do
    fullpath = Enum.reverse(String.split(path, ":"))
    page = hd(fullpath)
    namespaces = tl(fullpath)
    namespaces = namespaces |> Enum.reverse()
    Logger.info("Got page: #{inspect(page)} and namespaces: #{inspect(namespaces)}")
    [namespaces, page]
  end

  def page(conn, %{"path" => path}) do
    [namespaces, page_name] = split_path(path)
    # todo handle parent_id for namespace
    namespace =
      if length(namespaces) == 0 do
        %Squeak.Namespaces.Namespace{}
      else
        Squeak.Namespaces.Namespace.get_by_name_and_parent(List.last(namespaces), nil)
      end

    page =
      if namespace do
        Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace.id, page_name)
      else
        Squeak.Wiki.Page.get_by_namespace_id_and_name(nil, page_name)
      end

    if is_nil(page) do
      render(conn, "not_found.html",
        namespaces: namespaces,
        path: namespaces ++ [page_name],
        page_name: page_name,
        page: page
      )
    else
      render(conn, "page.html",
        namespaces: namespaces,
        path: namespaces ++ [page_name],
        page_name: page_name,
        page: page
      )
    end
  end
end
