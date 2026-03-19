defmodule Kerneldex.GitHub do
  @moduledoc """
  Parse GitHub blob URLs and fetch raw file content.
  """

  @raw_host "raw.githubusercontent.com"

  @doc """
  Parse a GitHub blob URL into its components.

  ## Examples

      iex> Kerneldex.GitHub.parse_blob_url("https://github.com/ROCm/aiter/blob/main/src/kernel.cu")
      {:ok, %{owner: "ROCm", repo: "aiter", ref: "main", path: "src/kernel.cu"}}

  """
  def parse_blob_url(url) when is_binary(url) do
    uri = URI.parse(url)

    case {uri.host, split_blob_path(uri.path)} do
      {"github.com", {:ok, parts}} ->
        {:ok, parts}

      {"github.com", :error} ->
        {:error, "URL must be a GitHub blob URL (github.com/:owner/:repo/blob/:ref/*path)"}

      _ ->
        {:error, "URL must be on github.com"}
    end
  end

  def parse_blob_url(_), do: {:error, "URL must be a string"}

  defp split_blob_path(nil), do: :error

  defp split_blob_path("/" <> path) do
    case String.split(path, "/", parts: 5) do
      [owner, repo, "blob", ref, file_path] when file_path != "" ->
        {:ok, %{owner: owner, repo: repo, ref: ref, path: file_path}}

      _ ->
        :error
    end
  end

  defp split_blob_path(_), do: :error

  @doc """
  Fetch raw file content from a GitHub blob URL.
  """
  def fetch_raw_content(url) do
    with {:ok, parts} <- parse_blob_url(url) do
      raw_url = "https://#{@raw_host}/#{parts.owner}/#{parts.repo}/#{parts.ref}/#{parts.path}"

      case :httpc.request(:get, {String.to_charlist(raw_url), []}, [timeout: 15_000], body_format: :binary) do
        {:ok, {{_, 200, _}, _headers, body}} ->
          {:ok, body}

        {:ok, {{_, status, _}, _headers, _body}} ->
          {:error, "GitHub returned #{status} for #{raw_url}"}

        {:error, reason} ->
          {:error, "Failed to fetch from GitHub: #{inspect(reason)}"}
      end
    end
  end

  @doc """
  Infer kernel metadata from a GitHub blob URL.
  Returns a map with :file_name, :language, and :source_project.
  """
  def infer_metadata(url) do
    with {:ok, parts} <- parse_blob_url(url) do
      file_name = Path.basename(parts.path)

      {:ok,
       %{
         "file_name" => file_name,
         "language" => infer_language(file_name),
         "source_project" => parts.repo
       }}
    end
  end

  defp infer_language(file_name) do
    case Path.extname(file_name) do
      ".cu" -> "CUDA"
      ".cuh" -> "CUDA"
      ".hip" -> "HIP"
      ".cpp" -> "HIP"
      ".hpp" -> "HIP"
      ".py" -> "Python"
      ".md" -> "docs"
      _ -> "unknown"
    end
  end
end
