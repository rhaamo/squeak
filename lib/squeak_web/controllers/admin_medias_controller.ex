defmodule SqueakWeb.AdminMediaController do
  use SqueakWeb, :controller
  alias Squeak.Medias.Media
  alias Squeak.Pagination
  require Ecto.Query

  def list(conn, params) do
    max_id = params["max_id"]
    since_id = params["since_id"]

    medias =
      Squeak.Medias.Media
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:medias],
        "max_id" => max_id,
        "since_id" => since_id
      })

    render(conn, "list.html", medias: medias)
  end

  def new(conn, _params) do
    changeset = Media.changeset(%Media{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"media" => media_params}) do
    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    {:ok, mime_type} =
      GenMagic.Pool.perform(Squeak.GenMagicPool, Path.expand(media_params["media"].path))

    params =
      media_params
      |> Map.put("updated_at", date)
      |> Map.put("inserted_at", date)
      |> Map.put("original_filename", media_params["media"].filename)
      |> Map.put("mime", mime_type.mime_type)

    changeset = Media.changeset(%Media{}, params)

    {:ok, _media} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:media, changeset)
      |> Ecto.Multi.update(:media_with_file, &Media.media_changeset(&1.media, params))
      |> Squeak.Repo.transaction()

    # TODO: handle errors

    conn
    |> put_flash(:info, "Media has been saved")
    |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
  end

  def edit(_conn, _params) do
  end

  def update(_conn, _params) do
  end

  def delete(_conn, _params) do
  end
end
