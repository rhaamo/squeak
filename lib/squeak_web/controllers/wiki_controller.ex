defmodule SqueakWeb.WikiController do
  use SqueakWeb, :controller
  require Logger

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns]
    apply(__MODULE__, action_name(conn), args)
  end

  def page(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
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
        path: fullpath,
        page_name: page_name,
        page: page
      )
    else
      render(conn, "page.html",
        namespaces: namespaces,
        path: fullpath,
        page_name: page_name,
        page: page
      )
    end
  end
end
