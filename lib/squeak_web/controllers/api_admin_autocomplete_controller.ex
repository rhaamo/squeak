defmodule SqueakWeb.ApiAdminAutocompleteController do
  use SqueakWeb, :controller

  def tags(conn, params) do

    like = params["like"]

    tags = Squeak.Tags.Tag.get_tags_like(like)
    render(conn, "tags.json", tags: tags)
  end

end
