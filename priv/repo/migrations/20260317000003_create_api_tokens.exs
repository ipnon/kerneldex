defmodule Kerneldex.Repo.Migrations.CreateApiTokens do
  use Ecto.Migration

  def change do
    create table(:api_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token_hash, :binary, null: false
      add :label, :text
      add :last_used_at, :utc_datetime_usec
      add :revoked_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:api_tokens, [:token_hash])
    create index(:api_tokens, [:user_id])
  end
end
