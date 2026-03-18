defmodule Kerneldex.Repo.Migrations.MakeNameAndSourceProjectNullable do
  use Ecto.Migration

  def change do
    alter table(:kernels) do
      modify :name, :text, null: true
      modify :source_project, :text, null: true
    end
  end
end
