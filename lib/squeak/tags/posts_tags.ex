defmodule Squeak.Tags.PostsTags do
  use Ecto.Schema

  schema "posts_tags" do
    belongs_to(:post, Squeak.Posts.Post)
    belongs_to(:tag, Squeak.Tags.Tag)
  end
end
