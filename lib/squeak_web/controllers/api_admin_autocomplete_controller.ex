defmodule SqueakWeb.ApiAdminAutocompleteController do
  use SqueakWeb, :controller

  def tags(conn, params) do

    q = params["q"]

    tags = Squeak.Tags.Tag.get_tags_like(q)
    render(conn, "tags.json", tags: tags)
  end

end
