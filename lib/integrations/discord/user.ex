defmodule Integrations.Discord.User do
  @type t :: %__MODULE__{
          id: String.t(),
          global_name: String.t(),
          email: String.t()
        }

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:global_name, :string)
    field(:email, :string)
  end

  @required_fields [:id, :global_name, :email]
  @optional_fields []

  def build!(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> apply_action!(:build)
  end
end
