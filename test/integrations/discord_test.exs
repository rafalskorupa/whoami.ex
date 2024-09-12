defmodule Integrations.DiscordTest do
  use ExUnit.Case, async: true

  alias Integrations.Discord
  alias Integrations.Discord.ApiMock, as: DiscordApi

  import Mox

  setup :verify_on_exit!

  @token %Integrations.Discord.Token{
    access_token: "access_token"
  }

  describe "exchange_code/1" do
    @code "code"
    test "it returns code" do
      expect(DiscordApi, :access_token, fn code ->
        assert code == @code

        {:ok, @token}
      end)

      assert {:ok, @token} == Discord.exchange_code(@code)
    end

    test "return api error" do
      expect(DiscordApi, :access_token, fn code ->
        assert code == @code

        {:error, :api_error}
      end)

      assert {:error, :api_error} == Discord.exchange_code(@code)
    end
  end

  describe "me/1" do
    @discord_user %Discord.User{
      id: "discord-id",
      global_name: "name",
      email: "rafal@skorupa.io"
    }

    test "it returns code" do
      expect(DiscordApi, :me, fn token ->
        assert token == @token

        {:ok, @discord_user}
      end)

      assert {:ok, @discord_user} == Discord.me(@token)
    end

    test "return api error" do
      expect(DiscordApi, :me, fn token ->
        assert token == @token

        {:error, :api_error}
      end)

      assert {:error, :api_error} == Discord.me(@token)
    end
  end
end
