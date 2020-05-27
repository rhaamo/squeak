defmodule Squeak.User do
  alias Squeak.Repo
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema, extensions: [PowResetPassword, PowEmailConfirmation]

  schema "users" do
    field :role, :string, null: false, default: "user"
    field :username, :string, null: false

    pow_user_fields()

    timestamps()
  end

  @spec changeset_role(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin))
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  @type t :: %Squeak.User{}

  @spec set_admin_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_admin_role(user) do
    user
    |> changeset_role(%{role: "admin"})
    |> Repo.update()
  end

  @spec set_user_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_user_role(user) do
    user
    |> changeset_role(%{role: "user"})
    |> Repo.update()
  end

  @spec create_user(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_user(params) do
    %Squeak.User{}
    |> changeset(params)
    |> Squeak.User.changeset_role(%{role: "user"})
    |> Repo.insert()
  end

  @spec create_admin(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_admin(params) do
    %Squeak.User{}
    |> changeset(params)
    |> changeset_role(%{role: "admin"})
    |> Repo.insert()
  end

end
