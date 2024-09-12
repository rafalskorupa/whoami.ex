defmodule Whoami.Repo do
  use Ecto.Repo,
    otp_app: :whoami,
    adapter: Ecto.Adapters.Postgres
end
