defmodule SqueakWeb.WikiEditController do
  use SqueakWeb, :controller
  require Logger

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns]
    apply(__MODULE__, action_name(conn), args)
  end

  def edit(conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end

  def update(conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end

  def delete(conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end
end
