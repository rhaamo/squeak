defmodule SqueakWeb.Plugs.PreloadTags do
  @behaviour Plug
  require Ecto.Query

  def init(default), do: default

  def call(conn, _default) do
    tags = Squeak.Tags.Tag.get_tags()
    Plug.Conn.assign(conn, :blog_tags, tags)
  end
end
