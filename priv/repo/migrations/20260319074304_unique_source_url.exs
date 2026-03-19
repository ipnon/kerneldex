defmodule Kerneldex.Repo.Migrations.UniqueSourceUrl do
  use Ecto.Migration

  def change do
    drop unique_index(:kernels, [:file_name])
    create unique_index(:kernels, [:source_url])
  end
end
