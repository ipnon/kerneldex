defmodule Kerneldex.Catalog.Kernel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kernels" do
    field :source_code, :string
    field :source_url, :string
    field :file_name, :string
    field :language, :string
    field :algorithm, :string
    field :hardware, {:array, :string}, default: []
    field :name, :string
    field :source_project, :string
    field :techniques, {:array, :string}, default: []
    field :notes, :string

    belongs_to :submitted_by, Kerneldex.Accounts.User

    timestamps()
  end

  @required ~w(source_code source_url file_name language algorithm)a
  @optional ~w(hardware name source_project techniques notes submitted_by_id)a

  def changeset(kernel, attrs) do
    kernel
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:source_url)
  end
end
