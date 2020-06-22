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

    namespaces_records = Squeak.Namespaces.Namespace.resolve_tree(namespaces)
    namespace_id = if Enum.member?(namespaces_records, nil) do
      # We have a non existing namespace, page will not exists
      nil
    else
      List.last(namespaces_records).id
    end

    page = Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace_id, page_name)

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

  def update(conn, %{"page" => page_params}, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
    namespaces_records = Squeak.Namespaces.Namespace.resolve_tree(namespaces)
    namespace_id = if Enum.member?(namespaces_records, nil) do
      # We have a non existing namespace, page will not exists
      nil
    else
      List.last(namespaces_records).id
    end

    page = Squeak.Wiki.Page.get_by_namespace_id_and_name(namespace_id, page_name)
    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    if is_nil(page) do
      parent_namespace = Squeak.Namespaces.Namespace.get_or_create_namespaces(namespaces)
      |> List.last

      params = page_params
      |> Map.put("name", page_name)
      |> Map.put("inserted_at", date)
      |> Map.put("namespace_id", parent_namespace.id)

      changeset = Squeak.Wiki.Page.changeset(%Squeak.Wiki.Page{}, params)

      if changeset.valid? do
        {:ok, _obj} = Squeak.Repo.insert(changeset)
        conn
        |> put_flash(:info, "Page created")
        |> redirect(to: SqueakWeb.FormatterHelpers.wiki_page_path(conn, page_name, namespaces))
      else
        render(conn, "edit.html",
          page: page,
          page_name: page_name,
          namespaces: namespaces,
          path: fullpath,
          changeset: changeset
        )
      end
    else
      _params = page_params
      |> Map.put("updated_at", date)
      # edit
    end
  end

  def delete(_conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end
end
