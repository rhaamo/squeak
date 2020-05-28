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

  def show(conn, %{"slug" => post_slug}) do
    post = Squeak.Posts.Post.get_post_by_slug(post_slug)
    |> Squeak.Repo.preload :user

    if is_nil(post) do
      conn
        |> render(:"404")
    end

    render(conn, "show.html", post: post)
  end
end
