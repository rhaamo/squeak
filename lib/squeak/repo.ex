defmodule Squeak.Repo do
  use Ecto.Repo,
    otp_app: :squeak,
    adapter: Ecto.Adapters.Postgres
end
