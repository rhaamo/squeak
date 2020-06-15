defmodule Squeak.Uploaders.Media do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb, :small, :medium, :large]

  defp get_simple_mime_type(file, scope) do
    if !Map.has_key?(file, :path) do
      scope.mime
      |> String.split("/")
      |> List.first()
    else
      if File.exists?(file.path) do
        {:ok, mime} = GenMagic.Pool.perform(Squeak.GenMagicPool, Path.expand(file.path))

        mime.mime_type
        |> String.split("/")
        |> List.first()
      else
        :error
      end
    end
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
