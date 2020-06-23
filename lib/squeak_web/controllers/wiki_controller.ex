defmodule SqueakWeb.WikiController do
  use SqueakWeb, :controller
  require Logger
  require Ecto.Query
  alias Squeak.Pagination

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

  def page_source(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
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
      conn
      |> put_status(404)
      |> text("Page not found")
    else
      conn
      |> put_resp_content_type("text/plain")
      |> render("page_source.md",
        page: page,
        page_name: page_name,
        namespaces: namespaces,
        fullpath: fullpath
      )
    end
  end

  def history(conn, _, %{page_name: page_name, namespaces: namespaces, fullpath: fullpath}) do
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
      render(conn, "history.html",
        namespaces: namespaces,
        path: fullpath,
        page_name: page_name,
        page: page,
        revisions: Revisionair.list_revisions(page)
      )
    end
  end

  def revision(conn, %{"revision" => revision}, %{
        page_name: page_name,
        namespaces: namespaces,
        fullpath: fullpath
      }) do
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
      rev_number =
        case Integer.parse(revision) do
          {n, _} -> n
          :error -> 0
        end

      {:ok, {rev, rev_no}} = Revisionair.get_revision(page, rev_number)

      render(conn, "page.html",
        namespaces: namespaces,
        path: fullpath,
        page_name: page_name,
        page: rev,
        rev_no: rev_no.revision
      )
    end
  end

  def tree(conn, _, _) do
    render(conn, "tree.html")
  end

  def search(conn, params, _) do
    q = params["q"]
    max_id = params["max_id"]
    since_id = params["since_id"]

    if q == "" or is_nil(q) do
      conn
      |> redirect(to: "/wiki/p/start")
    end

    pages =
      Squeak.Wiki.Page
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Squeak.Wiki.Search.run(q)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:posts],
        "max_id" => max_id,
        "since_id" => since_id
      })
      |> Squeak.Repo.preload(:namespace)

    render(conn, "search.html", pages: pages, q: q)
  end
end
