defmodule Squeak.Uploaders.Media do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb, :small, :medium, :large]
  @whitelist_pictures ~w(.jpg .jpeg .gif .png)
  @whitelist_videos ~w(.mp4 .webm)
  @whitelist_text ~w(.txt .c .cxx .cpp .h .lst)
  @whitelist_documents ~w(.pdf .docx .xslx .md .rst .html .htm .xml .json .yaml .yml .xls)
  @whitelist_other ~w(.zip .tar.gz .z .gz .sh)
  @whitelist @whitelist_pictures ++
               @whitelist_videos ++ @whitelist_text ++ @whitelist_documents ++ @whitelist_other

  defp get_simple_mime_type(path) do
    if File.exists?(path) do
      {:ok, mime} = GenMagic.Pool.perform(Squeak.GenMagicPool, Path.expand(path))
      mime.mime_type
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

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@whitelist, file_extension)
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, filename}) do
    "uploads/medias/#{filename}"
  end
end
