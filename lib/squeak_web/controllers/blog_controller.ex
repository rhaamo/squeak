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
    since_id = params["since_id"]

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.where([p], p.user_id == ^user.id)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => @posts_per_page,
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

    tag_name = tag.name

    posts =
      Ecto.Query.from(posts in Squeak.Posts.Post,
        inner_join: posts_tags in Squeak.Tags.PostsTags,
        on: posts_tags.post_id == posts.id,
        inner_join: tag in Squeak.Tags.Tag,
        on: tag.id == posts_tags.tag_id,
        where: tag.name == ^tag_name,
        where: posts.draft == false
      )
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Pagination.fetch_paginated(%{
        "limit" => @posts_per_page,
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
end
