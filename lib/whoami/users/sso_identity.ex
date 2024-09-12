defmodule Whoami.Users.SSOIdentity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_sso_identities" do
    field :provider, :string
    field :external_id, :string
    field :external_name, :string

    field :access_token, :string
    field :refresh_token, :string

    belongs_to(:user, Whoami.Users.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sso_identity, attrs) do
    sso_identity
    |> cast(attrs, [:provider, :external_id, :external_name, :access_token, :refresh_token])
    |> validate_required([:provider, :external_id, :external_name, :access_token])
    |> unique_constraint([:provider, :external_id])
    |> unique_constraint([:user_id, :provider])
  end
end
