defmodule Integrations.Discord.Api do
  alias Integrations.Discord.Token
  alias Integrations.Discord.User

  require Logger

  @callback access_token(String.t()) :: {:ok, Token.t()} | {:error, :api_error}
  @callback revoke_token(%{access_token: String.t()}) :: {:ok, any()} | {:error, :api_error}

  @callback me(%{access_token: String.t()}) :: {:ok, User.t()} | {:error, :api_error}

  @spec authorize_url() :: String.t()
  def authorize_url() do
    Application.get_env(:whoami, Integrations.Discord.Api)[:authorize_url]
  end

  @spec access_token(String.t()) :: {:ok, Token.t()} | {:error, :api_error}
  def access_token(code), do: impl().access_token(code)

  @spec revoke_token(any()) :: :ok | {:error, :api_error}
  def revoke_token(token), do: impl().revoke_token(token)

  @spec me(Token.t()) :: {:ok, User.t()} | {:error, :api_error}
  def me(token), do: impl().me(token)

  defp impl do
    Application.get_env(:whoami, :discord_api, Integrations.Discord.Api.Implementation)
  end

  defmodule Implementation do
    @behaviour Integrations.Discord.Api

    use Tesla

    @impl true
    def access_token(code) do
      data = %{
        client_id: client_id(),
        client_secret: client_secret(),
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri()
      }

      case Tesla.post(auth_client(), "/oauth2/token", data) do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          {:ok, Token.build!(body)}

        env ->
          Logger.warning("API Error: #{inspect(env)}")
          {:error, :api_error}
      end
    end

    @impl true
    def revoke_token(token) do
      data = %{
        client_id: client_id(),
        client_secret: client_secret(),
        token: token.access_token
      }

      case Tesla.post(auth_client(), "/oauth2/token/revoke", data) do
        {:ok, %Tesla.Env{status: 200}} ->
          :ok

        env ->
          Logger.warning("API Error: #{inspect(env)}")
          {:error, :api_error}
      end
    end

    @impl true
    def me(token) do
      token
      |> client()
      |> Tesla.get("/users/@me")
      |> case do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          {:ok, User.build!(body)}

        env ->
          Logger.warning("API Error: #{inspect(env)}")
          {:error, :api_error}
      end
    end

    defp auth_client() do
      Tesla.client([
        {Tesla.Middleware.BaseUrl, "https://discord.com/api/v10"},
        Tesla.Middleware.FormUrlencoded,
        Tesla.Middleware.DecodeJson
      ])
    end

    defp client(token) do
      Tesla.client([
        {Tesla.Middleware.BaseUrl, "https://discord.com/api/v10"},
        {Tesla.Middleware.BearerAuth, token: token.access_token},
        Tesla.Middleware.DecodeJson
      ])
    end

    defp client_id do
      Application.get_env(:whoami, Integrations.Discord.Api)[:client_id]
    end

    defp client_secret do
      Application.get_env(:whoami, Integrations.Discord.Api)[:client_secret]
    end

    defp redirect_uri do
      Application.get_env(:whoami, Integrations.Discord.Api)[:redirect_uri]
    end
  end
end
