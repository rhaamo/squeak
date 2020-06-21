defmodule SqueakWeb.WikiEditController do
  use SqueakWeb, :controller
  require Logger

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns]
    apply(__MODULE__, action_name(conn), args)
  end

  def edit(_conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end

  def update(_conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end

  def delete(_conn, _, %{page_name: _page_name, namespaces: _namespaces, fullpath: _fullpath}) do
  end
end
