defmodule SqueakWeb.BlogController do
  use SqueakWeb, :controller
  alias Squeak.Posts.Post
  require Logger
  require Ecto.Query

  def list(conn, _params) do
    posts = Squeak.Posts.Post
    |> Ecto.Query.order_by([a], desc: a.inserted_at)
    |> Squeak.Repo.all()
    |> Squeak.Repo.preload :user

    render(conn, "list.html", posts: posts)
  end
end
