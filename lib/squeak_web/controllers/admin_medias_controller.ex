defmodule SqueakWeb.AdminMediaController do
  use SqueakWeb, :controller
  alias Squeak.Medias.Media

  def list(conn, _params) do
    render(conn, "list.html")
  end

  def new(conn, _params) do
    changeset = Media.changeset(%Media{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(_conn, _params) do
  end

  def edit(_conn, _params) do
  end

  def update(_conn, _params) do
  end

  def delete(_conn, _params) do
  end
end
