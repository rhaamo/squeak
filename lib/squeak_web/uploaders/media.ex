defmodule Squeak.Uploaders.Media do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb, :small, :medium, :large]

  defp get_simple_mime_type(path) do
    if File.exists?(path) do
      {:ok, mime} = GenMagic.Pool.perform(Squeak.GenMagicPool, Path.expand(path))

      mime.mime_type
      |> String.split("/")
      |> List.first()
    else
      :error
    end
  end

  def transform(:thumb, {file, _filename}) do
    case get_simple_mime_type(file.path) do
      "image" -> {:convert, "-strip -thumbnail 90x^ -gravity center -extent 90x"}
      _ -> :skip
    end
  end

  def transform(:small, {file, _filename}) do
    case get_simple_mime_type(file.path) do
      "image" -> {:convert, "-strip -thumbnail 200x^ -gravity center -extent 200x"}
      _ -> :skip
    end
  end

  def transform(:medium, {file, _filename}) do
    case get_simple_mime_type(file.path) do
      "image" -> {:convert, "-strip -thumbnail 400x^ -gravity center -extent 400x"}
      _ -> :skip
    end
  end

  def transform(:large, {file, _filename}) do
    case get_simple_mime_type(file.path) do
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
  def storage_dir(_version, {_file, filename}) do
    "uploads/medias/#{filename}"
  end
end
