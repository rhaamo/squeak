defmodule SqueakWeb.BlogController do
  use SqueakWeb, :controller
  require Logger
  require Ecto.Query

  def list(conn, _params) do
    posts = Squeak.Posts.Post
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Squeak.Repo.all()
      |> Squeak.Repo.preload(:user)

    render(conn, "list.html", posts: posts)
  end

  def show(conn, %{"post_slug" => post_slug, "user_slug" => user_slug}) do
    user = Squeak.Users.User.get_user_by_slug(user_slug)
    if is_nil(user) do
      conn
        |> put_flash(:error, "User not found")
        |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    post = Squeak.Posts.Post.get_post_by_slug_and_user_id(post_slug, user.id)
      |> Squeak.Repo.preload(:user)

    if is_nil(post) do
      conn
        |> render(:"404")
    end

    render(conn, "show.html", post: post)
  end
end
