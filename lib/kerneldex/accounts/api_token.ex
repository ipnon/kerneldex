defmodule Kerneldex.Accounts.ApiToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_tokens" do
    field :token_hash, :binary
    field :label, :string
    field :last_used_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec

    # Virtual field — only populated at creation time
    field :raw_token, :string, virtual: true

    belongs_to :user, Kerneldex.Accounts.User

    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:label, :user_id])
    |> validate_required([:user_id])
  end
end
