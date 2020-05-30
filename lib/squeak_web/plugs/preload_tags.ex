defmodule SqueakWeb.Plugs.PreloadTags do
  require Ecto.Query

  def init(default), do: default

  def call(conn, _default) do
    tags = Squeak.Tags.Tag.get_tags(false)
    Plug.Conn.assign(conn, :blog_tags, tags)
  end
end
