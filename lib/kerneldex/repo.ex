defmodule Kerneldex.Repo do
  use Ecto.Repo,
    otp_app: :kerneldex,
    adapter: Ecto.Adapters.Postgres
end
