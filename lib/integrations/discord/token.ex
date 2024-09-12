defmodule Integrations.Discord.Token do
  @type t :: %__MODULE__{
          access_token: String.t(),
          refresh_token: String.t(),
          scope: String.t(),
          token_type: String.t(),
          expires_in: pos_integer()
        }

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:access_token, :string)
    field(:refresh_token, :string)
    field(:scope, :string)
    field(:token_type, :string)
    field(:expires_in, :integer)
  end

  @fields [:access_token, :refresh_token, :scope, :token_type, :expires_in]

  def build!(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> apply_action!(:build)
  end
end
