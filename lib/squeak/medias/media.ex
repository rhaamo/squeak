defmodule Squeak.Medias.Media do
  use Ecto.Schema
  use Waffle.Definition
  use Waffle.Ecto.Schema
  use Waffle.Ecto.Definition
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "medias" do
    field :filename, :string
    field :original_filename, :string
    field :type, :string
    field :mime, :string

    field :media, Squeak.Uploaders.Media.Type

    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    timestamps(type: :utc_datetime)
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [:filename, :original_filename, :type, :mime])
    |> cast_attachments(attrs, [:media])
    |> validate_required([:filename, :original_filename, :type, :mime, :media])
  end
end
