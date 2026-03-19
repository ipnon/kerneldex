defmodule Kerneldex.Repo.Migrations.UniqueSourceUrl do
  use Ecto.Migration

  def up do
    # Remove duplicate source_urls, keeping the oldest (lowest id)
    execute """
    DELETE FROM kernels
    WHERE id NOT IN (
      SELECT MIN(id) FROM kernels GROUP BY source_url
    )
    """

    drop unique_index(:kernels, [:file_name])
    create unique_index(:kernels, [:source_url])
  end

  def down do
    drop unique_index(:kernels, [:source_url])
    create unique_index(:kernels, [:file_name])
  end
end
