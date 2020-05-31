defmodule SqueakWeb.BlogController do
  use SqueakWeb, :controller
  alias Squeak.Pagination
  require Logger
  require Ecto.Query

  @posts_per_page 2

  def list(conn, params) do
    max_id = params["max_id"]
    since_id = params["since_id"]

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => @posts_per_page,
        "max_id" => max_id,
        "since_id" => since_id
      })
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    render(conn, "list.html", posts: posts, user: nil)
  end

  def list_by_user_slug(%{params: %{"user_slug" => user_slug}} = conn, params) do
    user = Squeak.Users.User.get_user_by_slug(user_slug)

    if is_nil(user) do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    max_id = params["max_id"]

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.where([p], p.user_id == ^user.id)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{"limit" => @posts_per_page, "max_id" => max_id})
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    render(conn, "list.html", posts: posts, user: user)
  end

  def show(conn, %{"post_slug" => post_slug, "user_slug" => user_slug}) do
    user = Squeak.Users.User.get_user_by_slug(user_slug)

    if is_nil(user) do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    post =
      Squeak.Posts.Post.get_post_by_slug_and_user_id(post_slug, user.id)
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    if is_nil(post) do
      conn
      |> render(:"404")
    end

    render(conn, "show.html", post: post)
  end
end
