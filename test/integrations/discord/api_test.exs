defmodule Whoami.Discord.ApiTest do
  use Whoami.TeslaCase, async: true

  alias Integrations.Discord.Api.Implementation, as: Api

  alias Integrations.Discord
  alias Integrations.Discord

  @client_id "DISCORD_CLIENT_ID"
  @client_secret "DISCORD_CLIENT_SECRET"
  @redirect_uri "https://whoami.skorupa.io/sso/discord/authorize"

  @access_token "access_token"
  @refresh_token "refresh_token"
  @expires_in 86_400
  @scope "identity"
  @token_type "access_token"

  @token %Discord.Token{
    access_token: @access_token,
    refresh_token: @refresh_token,
    expires_in: @expires_in,
    scope: @scope,
    token_type: @token_type
  }

  describe "Api.access_token/1" do
    test "it exchanges code for access_token" do
      code = "valid_code"

      Tesla.Mock.mock(fn
        %{method: :post} = env ->
          assert env.headers == [{"content-type", "application/x-www-form-urlencoded"}]

          assert URI.decode_query(env.body) == %{
                   "client_id" => @client_id,
                   "client_secret" => @client_secret,
                   "code" => code,
                   "grant_type" => "authorization_code",
                   "redirect_uri" => @redirect_uri
                 }

          %Tesla.Env{
            status: 200,
            body: %{
              "access_token" => @access_token,
              "refresh_token" => @refresh_token,
              "expires_in" => @expires_in,
              "scope" => @scope,
              "token_type" => @token_type
            }
          }
      end)

      assert {:ok, %Discord.Token{} = token} = Api.access_token(code)

      assert token.access_token == @access_token
      assert token.refresh_token == @refresh_token
      assert token.expires_in == @expires_in
      assert token.scope == @scope
      assert token.token_type == @token_type
    end

    test "it returns api error" do
      code = "invalid_code"

      Tesla.Mock.mock(fn
        %{method: :post} = env ->
          assert env.headers == [{"content-type", "application/x-www-form-urlencoded"}]

          assert URI.decode_query(env.body) == %{
                   "client_id" => @client_id,
                   "client_secret" => @client_secret,
                   "code" => code,
                   "grant_type" => "authorization_code",
                   "redirect_uri" => @redirect_uri
                 }

          %Tesla.Env{status: 401}
      end)

      assert_api_error_log(
        fn ->
          assert {:error, :api_error} = Api.access_token(code)
        end,
        "status: 401"
      )
    end
  end

  describe "Api.me/1" do
    @user_id "12345"
    @username "discord_username"
    @global_name "discord_global_name"
    @email "rafal@skorupa.io"

    test "it returns Discord User struct" do
      Tesla.Mock.mock(fn
        %{method: :get} = env ->
          assert env.url == "https://discord.com/api/v10/users/@me"
          assert env.headers == [{"authorization", "Bearer #{@token.access_token}"}]
          refute env.body

          %Tesla.Env{
            status: 200,
            body: %{
              "id" => @user_id,
              "username" => @username,
              "global_name" => @global_name,
              "email" => @email
            }
          }
      end)

      assert {:ok, %Discord.User{} = discord_user} = Api.me(@token)

      assert discord_user.id == @user_id
      assert discord_user.global_name == @global_name
      assert discord_user.email == @email
    end

    test "it returns api error" do
      Tesla.Mock.mock(fn
        %{method: :get} = env ->
          assert env.url == "https://discord.com/api/v10/users/@me"
          assert env.headers == [{"authorization", "Bearer #{@token.access_token}"}]
          refute env.body

          %Tesla.Env{status: 401}
      end)

      assert_api_error_log(
        fn ->
          {:error, :api_error} == Api.me(@token)
        end,
        "status: 401"
      )
    end
  end
end
