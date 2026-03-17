defmodule Kerneldex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :github_id, :integer, null: false
      add :github_login, :text, null: false
      add :github_avatar, :text
      add :email, :text
      add :role, :text, default: "user", null: false

      timestamps()
    end

    create unique_index(:users, [:github_id])
  end
end
