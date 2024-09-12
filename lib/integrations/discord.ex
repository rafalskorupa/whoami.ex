defmodule Integrations.Discord do
  @moduledoc """
  Module to interact with Discord API
  """

  alias Integrations.Discord.Api

  def key() do
    "discord"
  end

  def name() do
    "Discord"
  end

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

  def authorize_url(state) do
    "#{Api.authorize_url()}&state=#{state}"
  end

  def revoke_token(token) do
    Api.revoke_token(token)
  end
end
