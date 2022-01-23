defmodule Coda.Repo do
  use Ecto.Repo,
    otp_app: :coda,
    adapter: Ecto.Adapters.Postgres
end
