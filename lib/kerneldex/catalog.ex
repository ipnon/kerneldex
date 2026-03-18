defmodule Kerneldex.Catalog do
  import Ecto.Query
  alias Kerneldex.Repo
  alias Kerneldex.Catalog.Kernel

  def list_kernels(filters \\ %{}) do
    Kernel
    |> apply_filters(filters)
    |> order_by([k], asc: k.file_name)
    |> Repo.all()
  end

  def get_kernel!(id), do: Repo.get!(Kernel, id)
  def get_kernel(id), do: Repo.get(Kernel, id)

  def create_kernel(attrs) do
    %Kernel{}
    |> Kernel.changeset(attrs)
    |> Repo.insert()
  end

  def update_kernel(%Kernel{} = kernel, attrs) do
    kernel
    |> Kernel.changeset(attrs)
    |> Repo.update()
  end

  def delete_kernel(%Kernel{} = kernel) do
    Repo.delete(kernel)
  end

  def change_kernel(%Kernel{} = kernel, attrs \\ %{}) do
    Kernel.changeset(kernel, attrs)
  end

  def distinct_values(field) when field in ~w(algorithm language source_project)a do
    Kernel
    |> select([k], field(k, ^field))
    |> where([k], not is_nil(field(k, ^field)))
    |> distinct(true)
    |> order_by([k], asc: field(k, ^field))
    |> Repo.all()
  end

  def distinct_hardware_values do
    Kernel
    |> select([k], k.hardware)
    |> Repo.all()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:algorithm, v}, q when v not in [nil, ""] ->
        where(q, [k], k.algorithm == ^v)

      {:language, v}, q when v not in [nil, ""] ->
        where(q, [k], k.language == ^v)

      {:source_project, v}, q when v not in [nil, ""] ->
        where(q, [k], k.source_project == ^v)

      {:hardware, v}, q when v not in [nil, ""] ->
        where(q, [k], fragment("? @> ?", k.hardware, ^[v]))

      {:search, v}, q when v not in [nil, ""] ->
        term = "%#{v}%"
        where(q, [k], ilike(k.file_name, ^term) or ilike(k.algorithm, ^term) or ilike(k.name, ^term))

      _, q ->
        q
    end)
  end
end
