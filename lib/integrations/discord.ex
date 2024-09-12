defmodule Integrations.Discord do
  @moduledoc """
  Module to interact with Discord API
  """

  alias Integrations.Discord.Api

  # @impl true
  def exchange_code(code) do
    Api.access_token(code)
  end

  # @impl true
  def me(token) do
    with {:ok, discord_user} <- Api.me(token) do
      {:ok, discord_user}
    end
  end
end
