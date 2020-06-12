defmodule SqueakWeb.BlogController do
  use SqueakWeb, :controller
  alias Squeak.Pagination
  require Logger
  require Ecto.Query

  def list(conn, params) do
    max_id = params["max_id"]
    since_id = params["since_id"]

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:posts],
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
    since_id = params["since_id"]

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.where([p], p.user_id == ^user.id)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:posts],
        "max_id" => max_id,
        "since_id" => since_id
      })
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    render(conn, "list.html", posts: posts, user: user)
  end

  def list_by_tag_slug(%{params: %{"tag_slug" => tag_slug}} = conn, params) do
    tag = Squeak.Tags.Tag.get_tag_by_slug(tag_slug)

    if is_nil(tag) do
      conn
      |> put_flash(:error, "Tag not found")
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    max_id = params["max_id"]
    since_id = params["since_id"]

    posts =
      Squeak.Posts.Post.get_posts_by_tag_query(tag.name)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:posts],
        "max_id" => max_id,
        "since_id" => since_id
      })
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    render(conn, "list.html", posts: posts, tag: tag)
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

  def search(conn, params) do
    q = params["q"]
    max_id = params["max_id"]
    since_id = params["since_id"]

    if q == "" do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Squeak.Posts.Search.run(q)
      |> Pagination.fetch_paginated(%{
        "limit" => Squeak.States.Config.get(:pagination)[:posts],
        "max_id" => max_id,
        "since_id" => since_id
      })
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    render(conn, "list.html", posts: posts, user: nil, q: q)
  end
end
