defmodule KerneldexWeb.Api.KernelController do
  use KerneldexWeb, :controller

  alias Kerneldex.Catalog
  alias Kerneldex.GitHub

  def index(conn, params) do
    filters = %{
      algorithm: params["algorithm"],
      language: params["language"],
      source_project: params["source"],
      hardware: params["hardware"],
      search: params["q"]
    }

    kernels = Catalog.list_kernels(filters)
    json(conn, %{data: Enum.map(kernels, &kernel_json/1)})
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_kernel(id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Not found"})
      kernel -> json(conn, %{data: kernel_json(kernel)})
    end
  end

  def create(conn, %{"kernel" => kernel_params}) do
    kernel_params = Map.put(kernel_params, "submitted_by_id", conn.assigns.current_user.id)

    case maybe_fetch_from_github(kernel_params) do
      {:ok, kernel_params} ->
        case Catalog.create_kernel(kernel_params) do
          {:ok, kernel} ->
            conn |> put_status(:created) |> json(%{data: kernel_json(kernel)})

          {:error, changeset} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
        end

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: %{source_url: [reason]}})
    end
  end

  def algorithms(conn, _params) do
    counts = Catalog.algorithm_counts()
    json(conn, %{data: counts})
  end

  def update(conn, %{"id" => id, "kernel" => kernel_params}) do
    kernel = Catalog.get_kernel!(id)

    case Catalog.update_kernel(kernel, kernel_params) do
      {:ok, kernel} ->
        json(conn, %{data: kernel_json(kernel)})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    kernel = Catalog.get_kernel!(id)
    {:ok, _} = Catalog.delete_kernel(kernel)
    send_resp(conn, :no_content, "")
  end

  # If source_code is already provided, pass through. Otherwise fetch from GitHub URL.
  defp maybe_fetch_from_github(%{"source_code" => code} = params) when is_binary(code) and code != "" do
    {:ok, params}
  end

  defp maybe_fetch_from_github(%{"source_url" => url} = params) when is_binary(url) do
    with {:ok, content} <- GitHub.fetch_raw_content(url),
         {:ok, inferred} <- GitHub.infer_metadata(url) do
      # Inferred values are defaults — explicit params take precedence
      {:ok, Map.merge(inferred, Map.put(params, "source_code", content))}
    end
  end

  defp maybe_fetch_from_github(_params) do
    {:error, "source_url is required"}
  end

  defp kernel_json(kernel) do
    %{
      id: kernel.id,
      source_code: kernel.source_code,
      source_url: kernel.source_url,
      file_name: kernel.file_name,
      language: kernel.language,
      algorithm: kernel.algorithm,
      hardware: kernel.hardware,
      name: kernel.name,
      source_project: kernel.source_project,
      techniques: kernel.techniques,
      notes: kernel.notes
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
