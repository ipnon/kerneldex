defmodule Mix.Tasks.Version do
  @shortdoc "Show or bump the project version (mix version [patch|minor|major])"
  @moduledoc """
  Show or bump the version in both mix.exs and cli/Cargo.toml.

      mix version          # print current version
      mix version patch    # 0.1.0 → 0.1.1
      mix version minor    # 0.1.0 → 0.2.0
      mix version major    # 0.1.0 → 1.0.0
  """

  use Mix.Task

  @version_files [
    {"mix.exs", ~r/version: "(\d+\.\d+\.\d+)"/},
    {"cli/Cargo.toml", ~r/^version = "(\d+\.\d+\.\d+)"/m}
  ]

  @impl true
  def run([]) do
    Mix.shell().info(current_version())
  end

  def run([bump]) when bump in ~w(patch minor major) do
    current = current_version()
    next = bump_version(current, String.to_atom(bump))

    for {file, pattern} <- @version_files do
      path = Path.join(Mix.Project.project_file() |> Path.dirname(), file)
      content = File.read!(path)
      updated = Regex.replace(pattern, content, fn full, _old ->
        String.replace(full, current, next)
      end)
      File.write!(path, updated)
    end

    Mix.shell().info("#{current} → #{next}")
  end

  def run(_), do: Mix.shell().error("Usage: mix version [patch|minor|major]")

  defp current_version do
    Mix.Project.config()[:version]
  end

  defp bump_version(version, part) do
    [major, minor, patch] =
      version |> String.split(".") |> Enum.map(&String.to_integer/1)

    case part do
      :patch -> "#{major}.#{minor}.#{patch + 1}"
      :minor -> "#{major}.#{minor + 1}.0"
      :major -> "#{major + 1}.0.0"
    end
  end
end
