defmodule Squeak.Medias.Media do
  use Ecto.Schema
  use Waffle.Definition
  use Waffle.Ecto.Schema
  use Waffle.Ecto.Definition
  import Ecto.Query
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "medias" do
    field :filename, :string
    field :original_filename, :string
    field :mime, :string

    field :media, Squeak.Uploaders.Media.Type

    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    timestamps(type: :utc_datetime)
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [:filename, :original_filename, :mime])
    |> validate_required([:filename, :original_filename, :mime])
  end

  def media_changeset(media, attrs) do
    media
    |> cast_attachments(attrs, [:media])
    |> validate_required([:media])
  end

  defp media_by_flake_id_query(flake_id) do
    from(t in Squeak.Medias.Media, where: t.flake_id == ^flake_id)
  end

  def get_media_by_flake_id(flake_id) do
    flake_id
    |> media_by_flake_id_query
    |> Squeak.Repo.one()
  end
end
