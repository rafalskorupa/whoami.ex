ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Whoami.Repo, :manual)

Mox.defmock(Integrations.Discord.ApiMock, for: Integrations.Discord.Api)
Application.put_env(:whoami, :discord_api, Integrations.Discord.ApiMock)
