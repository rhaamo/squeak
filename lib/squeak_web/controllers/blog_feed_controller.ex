defmodule SqueakWeb.BlogFeedController do
  use SqueakWeb, :controller
  alias Atomex.{Feed, Entry}
  require Logger
  require Ecto.Query

  @limit_posts_in_feed 10

  defp get_entry(post, conn) do
    author_uri =
      SqueakWeb.Router.Helpers.blog_url(conn, :list_by_user_slug, post.user.slug)
      |> URI.decode()

    entry_uri = SqueakWeb.Router.Helpers.blog_url(conn, :show, post.user.slug, post.slug)

    Entry.new(entry_uri, post.inserted_at, post.subject)
    |> Entry.author(post.user.username, uri: author_uri)
    |> Entry.content(SqueakWeb.FormatterHelpers.unmarkdownize_unsafe(post.content), type: "html")
    |> Entry.build()
  end

  def list(conn, _params) do
    self_uri =
      SqueakWeb.Router.Helpers.blog_feed_url(conn, :list)
      |> URI.decode()

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Ecto.Query.limit(@limit_posts_in_feed)
      |> Squeak.Repo.all()
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    feed =
      Feed.new(self_uri, DateTime.utc_now(), "All blog posts")
      |> Feed.link(self_uri, rel: "self")
      |> Feed.entries(Enum.map(posts, &get_entry(&1, conn)))
      |> Feed.build()
      |> Atomex.generate_document()

    conn
    |> put_resp_content_type("application/atom+xml")
    |> send_resp(200, feed)
  end

  def list_by_user_slug(%{params: %{"user_slug" => user_slug}} = conn, _params) do
    user = Squeak.Users.User.get_user_by_slug(user_slug)

    if is_nil(user) do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.where([p], p.user_id == ^user.id)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Ecto.Query.limit(@limit_posts_in_feed)
      |> Squeak.Repo.all()
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    self_uri =
      SqueakWeb.Router.Helpers.blog_feed_url(conn, :list_by_user_slug, user.slug)
      |> URI.decode()

    feed =
      Feed.new(self_uri, DateTime.utc_now(), "All blog posts for user #{user.username}")
      |> Feed.link(self_uri, rel: "self")
      |> Feed.entries(Enum.map(posts, &get_entry(&1, conn)))
      |> Feed.build()
      |> Atomex.generate_document()

    conn
    |> put_resp_content_type("application/atom+xml")
    |> send_resp(200, feed)
  end

  def list_by_tag_slug(%{params: %{"tag_slug" => tag_slug}} = conn, _params) do
    tag = Squeak.Tags.Tag.get_tag_by_slug(tag_slug)

    if is_nil(tag) do
      conn
      |> put_flash(:error, "Tag not found")
      |> redirect(to: SqueakWeb.Router.Helpers.blog_path(conn, :list))
    end

    posts =
      Squeak.Posts.Post.get_posts_by_tag_query(tag.name)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Ecto.Query.limit(@limit_posts_in_feed)
      |> Squeak.Repo.all()
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    self_uri =
      SqueakWeb.Router.Helpers.blog_feed_url(conn, :list_by_tag_slug, tag.slug)
      |> URI.decode()

    feed =
      Feed.new(self_uri, DateTime.utc_now(), "All blog posts for tag #{tag.name}")
      |> Feed.link(self_uri, rel: "self")
      |> Feed.entries(Enum.map(posts, &get_entry(&1, conn)))
      |> Feed.build()
      |> Atomex.generate_document()

    conn
    |> put_resp_content_type("application/atom+xml")
    |> send_resp(200, feed)
  end
end
