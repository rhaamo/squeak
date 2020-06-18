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

    params =
      media_params
      |> Map.put("updated_at", date)
      |> Map.put("inserted_at", date)
      |> Map.put("original_filename", media_params["media"].filename)
      |> Map.put("mime", media_params["media"].content_type)

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

  def edit(conn, %{"id" => media_id}) do
    media = Squeak.Repo.get_by(Squeak.Medias.Media, flake_id: media_id)

    if is_nil(media) do
      conn
      |> put_flash(:error, "Media not found")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
    end

    changeset = Squeak.Medias.Media.changeset(media, %{})
    render(conn, "edit.html", changeset: changeset, media_id: media_id, media: media)
  end

  def update(conn, %{"id" => media_id, "media" => media_params}) do
    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    media = Squeak.Repo.get_by(Squeak.Medias.Media, flake_id: media_id)

    if is_nil(media) do
      conn
      |> put_flash(:error, "Media not found")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
    end

    params =
      media_params
      |> Map.put("updated_at", date)

    if Map.has_key?(media_params, "media") do
      params =
        params
        |> Map.put("original_filename", media_params["media"].filename)
        |> Map.put("mime", media_params["media"].content_type)

      changeset = Media.changeset(media, params)

      {:ok, _media} =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:media, changeset)
        |> Ecto.Multi.update(:media_with_file, &Media.media_changeset(&1.media, params))
        |> Squeak.Repo.transaction()

      conn
      |> put_flash(:info, "Media updated")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :show, media.flake_id))
    else
      changeset = Media.changeset(media, params)

      if changeset.valid? do
        {:ok, _obj} = Squeak.Repo.update(changeset)

        conn
        |> put_flash(:info, "Media updated")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :show, media.flake_id))
      else
        render(conn, "edit.html", changeset: %{changeset | action: :insert}, media_id: media_id)
      end
    end
  end

  def delete(conn, %{"id" => media_id}) do
    media = Squeak.Repo.get_by(Squeak.Medias.Media, flake_id: media_id)

    if is_nil(media) do
      conn
      |> put_flash(:error, "Media not found")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
    end

    case Squeak.Repo.delete(media) do
      {:ok, struct} ->
        :ok = Squeak.Uploaders.Media.delete({struct.filename, struct})

        conn
        |> put_flash(:info, "Media deleted")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))

      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Cannot delete media")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
    end
  end

  def show(conn, %{"id" => media_id}) do
    media = Squeak.Repo.get_by(Squeak.Medias.Media, flake_id: media_id)

    if is_nil(media) do
      conn
      |> put_flash(:error, "Media not found")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_media_path(conn, :list))
    end

    render(conn, "show.html", media: media)
  end
end
