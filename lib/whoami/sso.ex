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

  def action(token) do
    case verify_state(token) do
      {:ok, %{action: action}}
      when action in ["sign_in", "sign_up"] ->
        {:ok, :authorize}

      {:ok, %{action: "connect", user_id: user_id}} ->
        {:ok, {:connect, user_id}}

      _ ->
        {:error, :invalid_state}
    end
  end

  def providers() do
    [
      Integrations.Discord
    ]
  end

  def name(provider) do
    provider.name()
  end

  def key(provider) do
    provider.key()
  end

  @state_key "sso_callback"
  @max_age 60

  def encode_state(state) do
    Phoenix.Token.sign(WhoamiWeb.Endpoint, @state_key, state)
  end

  def verify_state(token) do
    Phoenix.Token.verify(WhoamiWeb.Endpoint, @state_key, token, max_age: @max_age)
  end

  def sign_in_link(provider) do
    %{action: "sign_in"}
    |> encode_state()
    |> provider.authorize_url()
  end

  def sign_up_link(provider) do
    %{action: "sign_up"}
    |> encode_state()
    |> provider.authorize_url()
  end

  def connect_link(provider, user_id) do
    %{action: "connect", user_id: user_id}
    |> encode_state()
    |> provider.authorize_url()
  end

  def delete_identity(provider, identity) do
    with {:ok, provider_module} <- get_provider(provider) do
      provider_module.revoke_token(identity)
    end
  end

  def get_provider!(provider) do
    {:ok, provider} = get_provider(provider)
    provider
  end

  def get_provider("discord"), do: {:ok, Integrations.Discord}
  def get_provider(_), do: {:error, :invalid_provider}
end
