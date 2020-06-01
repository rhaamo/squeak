defmodule SqueakWeb.ApiAdminAutocompleteController do
  use SqueakWeb, :controller

  def tags(conn, _params) do
    tags = Squeak.Tags.Tag.get_tags
    render(conn, "tags.json", tags: tags)
  end

end
