defmodule Whoami.SSO do
  alias Whoami.SSO

  def authorize(provider, code) do
    with {:ok, provider_module} <- get_provider(provider),
         {:ok, token} <- provider_module.exchange_code(code),
         {:ok, me} <- provider_module.me(token) do
      {:ok,
       %SSO.ExternalIdentity{
         external_id: me.id,
         email: me.email,
         provider: provider,
         name: me.global_name,
         access_token: token.access_token
       }}
    end
  end

  def get_provider("discord"), do: {:ok, Integrations.Discord}
  def get_provider(_), do: {:error, :invalid_provider}
end
