defmodule Squeak.Uploaders.Media do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # This uploader is used by Squeak.Medias.Media (medias gallery) and Squeak.Inventory.Media (medias of hw listings)

  @versions [:original, :thumb, :small, :medium, :large]

  defp get_simple_mime_type(_file, scope) do
    scope.mime
    |> String.split("/")
    |> List.first()
  end

  def transform(:thumb, {file, scope}) do
    case get_simple_mime_type(file, scope) do
      "image" -> {:convert, "-strip -thumbnail 160x^ -gravity center -extent 160x"}
      _ -> :skip
    end
  end

  def transform(:small, {file, scope}) do
    case get_simple_mime_type(file, scope) do
      "image" -> {:convert, "-strip -thumbnail 200x^ -gravity center -extent 200x"}
      _ -> :skip
    end
  end

  def transform(:medium, {file, scope}) do
    case get_simple_mime_type(file, scope) do
      "image" -> {:convert, "-strip -thumbnail 400x^ -gravity center -extent 400x"}
      _ -> :skip
    end
  end

  def transform(:large, {file, scope}) do
    case get_simple_mime_type(file, scope) do
      "image" -> {:convert, "-strip -thumbnail 600x^ -gravity center -extent 600x"}
      _ -> :skip
    end
  end

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/medias/#{scope.flake_id}"
  end
end
