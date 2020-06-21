defmodule SqueakWeb.WikiEditController do
  use SqueakWeb, :controller
  require Logger

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns]
    apply(__MODULE__, action_name(conn), args)
  end

  def edit(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
    Logger.debug(
      "page_name: " <>
        inspect(page_name) <>
        " namespaces: " <> inspect(namespaces) <> " fullpath: " <> inspect(fullpath)
    )

    # todo handle parent_id for namespace
    namespace =
      if length(namespaces) == 0 do
        %Squeak.Namespaces.Namespace{}
      else
        Squeak.Namespaces.Namespace.get_by_name_and_parent(List.last(namespaces), nil)
      end

    page = Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace.id, page_name)

    if is_nil(page) do
      changeset = Squeak.Wiki.Page.changeset(%Squeak.Wiki.Page{}, %{})

      render(conn, "edit.html",
        page: page,
        page_name: page_name,
        namespaces: namespaces,
        path: fullpath,
        changeset: changeset
      )
    else
      changeset = Squeak.Wiki.Page.changeset(page, %{})

      render(conn, "edit.html",
        page: page,
        page_name: page_name,
        namespaces: namespaces,
        path: fullpath,
        changeset: changeset
      )
    end
  end

  def update(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
    # todo handle parent_id for namespace
    namespace =
      if length(namespaces) == 0 do
        %Squeak.Namespaces.Namespace{}
      else
        Squeak.Namespaces.Namespace.get_by_name_and_parent(List.last(namespaces), nil)
      end

    page = Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace.id, page_name)

    if is_nil(page) do
      # new
    else
      # edit
    end
  end

  def delete(_conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end
end
