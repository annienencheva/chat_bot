defmodule ChatBot.Repo do
  use Ecto.Repo,
    otp_app: :chat_bot,
    adapter: Ecto.Adapters.Postgres
end
