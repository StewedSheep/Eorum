defmodule Proj.Repo do
  use Ecto.Repo,
    otp_app: :proj,
    adapter: Ecto.Adapters.Postgres
end
