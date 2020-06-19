# This file was adapted from:
# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Squeak.Gopher.Server do
  use GenServer
  require Logger

  def start_link(_) do
    config = Squeak.States.Config.get(:gopher)
    ip = Map.get(config, :ip, {0, 0, 0, 0})
    port = Map.get(config, :port, 1234)

    if Map.get(config, :enabled, false) do
      GenServer.start_link(__MODULE__, [ip, port], [])
    else
      Logger.info("Gopher server disabled")
      :ignore
    end
  end

  def init([ip, port]) do
    ip_str = ip |> Tuple.to_list() |> Enum.join(".")
    Logger.info("Starting gopher server on #{ip_str}:#{port}")

    :ranch.start_listener(
      :gopher,
      100,
      :ranch_tcp,
      [ip: ip, port: port],
      __MODULE__.ProtocolHandler,
      []
    )

    {:ok, %{ip: ip, port: port}}
  end
end

defmodule Squeak.Gopher.Server.ProtocolHandler do
  require Ecto.Query

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, [] = _opts) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, 5000) do
      {:ok, data} ->
        data = String.trim_trailing(data, "\r\n")
        transport.send(socket, response(data))
        :ok = transport.close(socket)

      _ ->
        :ok = transport.close(socket)
    end
  end

  def info(text) do
    text = String.replace(text, ~r/[\t\n]/, "")

    String.split(text, "\r")
    |> Enum.map(fn text ->
      "i#{text}\tfake\t(NULL)\t0\r\n"
    end)
    |> Enum.join("")
  end

  def link(name, selector, type \\ 1) do
    address = SqueakWeb.Endpoint.host()
    port = Squeak.States.Config.get(:gopher) |> Map.get(:port, 1234)
    "#{type}#{name}\t#{selector}\t#{address}\t#{port}\r\n"
  end

  def render_post(post, preview \\ nil) do
    tags = Enum.map(post.tags, fn x -> x.name end) |> Enum.join(", ")

    post_content =
      case preview do
        nil ->
          post.content |> String.split(["\n", "\r", "\r\n"]) |> Enum.join("\r")

        _ ->
          post.content
          |> String.split(["\n", "\r", "\r\n"])
          |> Enum.slice(0, preview)
          |> Enum.join("\r")
      end

    link("Post by #{post.user.username}: #{post.subject}", "/blog/post/#{post.flake_id}") <>
      info(
        "Posted on: #{SqueakWeb.FormatterHelpers.date_format_iso(post.inserted_at)}, tags: #{tags}"
      ) <>
      "i\tfake\t(NULL)\t0\r\n" <>
      info(post_content <> "\r...")
  end

  def render_posts(posts) do
    posts
    |> Enum.map(fn post ->
      render_post(post, 10)
    end)
    |> Enum.join("i\tfake\t(NULL)\t0\r\n")
  end

  def response("") do
    app_name = Squeak.States.Config.get(:app_name)

    info("Welcome to #{app_name}") <>
      link("Blog", "/blog") <>
      link("Wiki", "/wiki") <> ".\r\n"
  end

  def response("/blog") do
    posts =
      Squeak.Posts.Post
      |> Ecto.Query.where([a], a.draft == false)
      |> Ecto.Query.order_by([a], desc: a.inserted_at)
      |> Ecto.Query.limit(10)
      |> Squeak.Repo.all()
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)
      |> render_posts

    info("List of last 10 blog posts") <> posts <> ".\r\n"
  end

  def response("/blog/post/" <> id) do
    post =
      Squeak.Posts.Post.get_post_by_flake_id(id)
      |> Squeak.Repo.preload(:user)
      |> Squeak.Repo.preload(:tags)

    if is_nil(post) do
      info("Not found") <> ".\r\n"
    else
      render_post(post) <> ".\r\n"
    end
  end

  def response("/wiki") do
    info("not yet implemented") <> ".\r\n"
  end
end
