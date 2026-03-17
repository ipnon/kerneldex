defmodule Kerneldex.Repo.Migrations.CreateKernels do
  use Ecto.Migration

  def change do
    create table(:kernels) do
      add :name, :text, null: false
      add :file_name, :text, null: false
      add :source_url, :text
      add :source_project, :text, null: false
      add :language, :text, null: false
      add :algorithm, :text, null: false
      add :hardware, {:array, :text}, default: []
      add :techniques, {:array, :text}, default: []
      add :notes, :text
      add :submitted_by_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:kernels, [:file_name])
    create index(:kernels, [:hardware], using: :gin)
    create index(:kernels, [:techniques], using: :gin)
    create index(:kernels, [:algorithm])
    create index(:kernels, [:language])
    create index(:kernels, [:source_project])
  end
end
