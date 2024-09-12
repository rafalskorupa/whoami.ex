defmodule Whoami.Repo.Migrations.CreateUserSsoIdentities do
  use Ecto.Migration

  def change do
    create table(:user_sso_identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :external_id, :string
      add :external_name, :string
      add :access_token, :string
      add :refresh_token, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:user_sso_identities, [:user_id])
    create unique_index(:user_sso_identities, [:provider, :external_id])
    create unique_index(:user_sso_identities, [:user_id, :provider])
  end
end
