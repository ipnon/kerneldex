defmodule Kerneldex.Repo.Migrations.AddSourceCodeRequireSourceUrl do
  use Ecto.Migration

  def change do
    alter table(:kernels) do
      add :source_code, :text, null: false, default: ""
    end

    # Make source_url required and name optional
    execute "UPDATE kernels SET source_url = '' WHERE source_url IS NULL"
    alter table(:kernels) do
      modify :source_url, :string, null: false
      modify :name, :string, null: true
    end
  end
end
