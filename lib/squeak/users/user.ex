defmodule Squeak.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema, extensions: [PowResetPassword, PowEmailConfirmation]
  import Ecto.Changeset

  schema "users" do
    field :role, :string, null: false, default: "user"
    field :username, :string, null: false

    pow_user_fields()

    timestamps()
  end

  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin))
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:username])
    |> validate_required([:username])
  end
end
