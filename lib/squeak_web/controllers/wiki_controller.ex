defmodule SqueakWeb.WikiController do
  use SqueakWeb, :controller
  require Logger

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns]
    apply(__MODULE__, action_name(conn), args)
  end

  def page(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
    namespaces_records = Squeak.Namespaces.Namespace.resolve_tree(namespaces)

    namespace_id =
      if Enum.member?(namespaces_records, nil) do
        # We have a non existing namespace, page will not exists
        nil
      else
        List.last(namespaces_records).id
      end

    page = Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace_id, page_name)

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

  def tree(conn, _, _) do
    render(conn, "tree.html")
  end
end
