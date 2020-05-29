defmodule Squeak.Posts.Post.SubjectSlug do
  @moduledoc """
  Generates slugs for posts.
  """

  use EctoAutoslugField.Slug, from: :subject, to: :slug, always_change: true

  alias Squeak.Posts.Post

  @slug_separator "-"

  @doc """
  Builds a slug.
  """
  @spec build_slug(keyword, Ecto.Changeset.t()) :: String.t()
  def build_slug(sources, changeset) do
    slug = super(sources, changeset)

    build_unique_slug(slug, changeset)
  end

  @spec build_unique_slug(String.t(), Ecto.Changeset.t()) :: String.t()
  defp build_unique_slug(slug, changeset) do
    case Post.get_post_by_slug(slug) do
      nil ->
        slug

      _post ->
        slug
        |> increment_slug()
        |> build_unique_slug(changeset)
    end
  end

  @spec increment_slug(String.t()) :: String.t()
  defp increment_slug(slug) do
    case List.pop_at(String.split(slug, @slug_separator), -1) do
      {nil, _} ->
        slug

      {suffix, slug_parts} ->
        case Integer.parse(suffix) do
          {id, _} ->
            Enum.join(slug_parts, @slug_separator) <>
              @slug_separator <>
              Integer.to_string(id + 1)

          :error ->
            "#{slug}#{@slug_separator}1"
        end
    end
  end
end
