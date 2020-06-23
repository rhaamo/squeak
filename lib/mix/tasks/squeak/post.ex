defmodule Mix.Tasks.Squeak.Post do
  use Mix.Task
  alias Squeak.Posts.Post
  import Mix.Squeak
  require Logger

  @shortdoc "Posts related operations"
  @moduledoc File.read!("docs/cli_tasks/posts.md")

  # Post will be ignored if another one already exists with the same title and username
  defp process_post(frontmatter, markdown, user, options) do
    post = Squeak.Posts.Post.get_post_by_subject(frontmatter["title"])

    if is_nil(post) do
      post_date = Timex.parse!(frontmatter["date"], "{YYYY}-{M}-{D}")
      draft = Keyword.get(options, :draft, false)

      tags =
        frontmatter["tags"]
        |> String.downcase()
        |> String.split(",")

      params =
        %{}
        |> Map.put("user_id", user.id)
        |> Map.put("updated_at", post_date)
        |> Map.put("inserted_at", post_date)
        |> Map.put("subject", frontmatter["title"])
        |> Map.put("tags", tags)
        |> Map.put("content", markdown)
        |> Map.put("draft", draft)

      changeset = Post.changeset(%Post{}, params)

      if changeset.valid? do
        {:ok, _obj} = Squeak.Repo.insert(changeset)
        Logger.info("post saved.")
      else
        Logger.error("cannot save post.")
      end
    else
      Logger.info("Post already exists, ignoring.")
    end
  end

  def run(["import", username | rest]) do
    start_apps()

    user = Squeak.Users.User.get_user_by_username(username)

    {options, [], []} =
      OptionParser.parse(rest,
        strict: [
          draft: :boolean
        ]
      )

    if is_nil(user) do
      Logger.error("User '#{username}' doesn't exists")
    else
      Path.wildcard("import/*.md")
      |> Enum.each(fn path ->
        Logger.info("- Parsing file #{path}")
        content = File.read!(path)
        [frontmatter, markdown] = Squeak.Frontmatter.handle(content)
        Logger.info("Title: #{frontmatter["title"]}")
        Logger.info("Tags: #{frontmatter["tags"]}")
        Logger.info("Published on: #{frontmatter["date"]}")
        process_post(frontmatter, markdown, user, options)
      end)
    end
  end
end
