defmodule WhoamiWeb.SSOSessionController do
  use WhoamiWeb, :controller

  alias Whoami.SSO
  alias Whoami.Users

  alias WhoamiWeb.UserAuth

  require Logger

  def create(conn, %{"provider" => provider, "code" => code}) do
    with {:ok, identity} <- SSO.authorize(provider, code),
         {:login, nil} <- {:login, Users.get_user_by_identity(identity)},
         {:ok, user} <- Users.register_user_with_identity(identity) do
      log_in_user(conn, user, "Account created successfully!")
    else
      {:login, user} ->
        log_in_user(conn, user, "Welcome back!")

      {:error, :email_already_taken} ->
        redirect_with_error(
          conn,
          "Seems like there is an account with email connected to your #{provider} account. Login instead."
        )

      {:error, :api_error} ->
        redirect_with_error(
          conn,
          "#{provider} error"
        )

      {:error, _} = error ->
        Logger.warning("#{__MODULE__}.create/3 unexpected error: #{inspect(error)}")

        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  defp log_in_user(conn, user, flash) do
    conn
    |> put_flash(:info, flash)
    |> UserAuth.log_in_user(user)
  end

  defp redirect_with_error(conn, flash) do
    conn
    |> put_flash(:error, flash)
    |> redirect(to: ~p"/users/log_in")
  end
end
