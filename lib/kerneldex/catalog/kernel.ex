defmodule Kerneldex.Catalog.Kernel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kernels" do
    field :name, :string
    field :file_name, :string
    field :source_url, :string
    field :source_project, :string
    field :language, :string
    field :algorithm, :string
    field :hardware, {:array, :string}, default: []
    field :techniques, {:array, :string}, default: []
    field :notes, :string

    belongs_to :submitted_by, Kerneldex.Accounts.User

    timestamps()
  end

  @required ~w(name file_name source_project language algorithm)a
  @optional ~w(source_url hardware techniques notes submitted_by_id)a

  def changeset(kernel, attrs) do
    kernel
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:file_name)
  end
end
