defmodule Prag.Repo do
  use Ecto.Repo,
    otp_app: :prag,
    adapter: Ecto.Adapters.Postgres
end
