defmodule Whoami.SSO.ExternalIdentity do
  defstruct [:provider, :external_id, :name, :email, :access_token]

  @type t :: %__MODULE__{
          external_id: String.t(),
          email: String.t(),
          name: String.t(),
          provider: String.t(),
          access_token: String.t()
        }
end
