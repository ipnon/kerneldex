defmodule Kerneldex.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :github_id, :integer
    field :github_login, :string
    field :github_avatar, :string
    field :email, :string
    field :role, :string, default: "user"

    has_many :kernels, Kerneldex.Catalog.Kernel, foreign_key: :submitted_by_id
    has_many :api_tokens, Kerneldex.Accounts.ApiToken

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:github_id, :github_login, :github_avatar, :email, :role])
    |> validate_required([:github_id, :github_login])
    |> unique_constraint(:github_id)
  end
end
