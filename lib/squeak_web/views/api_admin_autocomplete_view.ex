defmodule SqueakWeb.ApiAdminAutocompleteView do
  use SqueakWeb, :view

  def render("tags.json", %{tags: tags}) do
    %{tags: render_many(tags, SqueakWeb.ApiAdminAutocompleteView, "tag.json")}
  end

  def render("tag.json", %{api_admin_autocomplete: tag}) do
    %{name: tag.name, slug: tag.slug}
  end
end
