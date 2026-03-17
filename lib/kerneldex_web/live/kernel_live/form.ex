defmodule KerneldexWeb.KernelLive.Form do
  use KerneldexWeb, :live_view

  alias Kerneldex.Catalog

  on_mount {KerneldexWeb.Plugs.Auth, :require_auth}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    kernel = Catalog.get_kernel!(id)
    changeset = Catalog.change_kernel(kernel)

    {:ok,
     socket
     |> assign(:page_title, "Edit Kernel")
     |> assign(:kernel, kernel)
     |> assign_form(changeset)}
  end

  def mount(_params, _session, socket) do
    changeset = Catalog.change_kernel(%Catalog.Kernel{})

    {:ok,
     socket
     |> assign(:page_title, "Submit Kernel")
     |> assign(:kernel, nil)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"kernel" => kernel_params}, socket) do
    kernel = socket.assigns.kernel || %Catalog.Kernel{}

    changeset =
      kernel
      |> Catalog.change_kernel(kernel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"kernel" => kernel_params}, socket) do
    kernel_params = Map.put(kernel_params, "submitted_by_id", socket.assigns.current_user.id)

    # Parse comma-separated arrays
    kernel_params =
      kernel_params
      |> parse_array("hardware")
      |> parse_array("techniques")

    case socket.assigns.kernel do
      nil -> Catalog.create_kernel(kernel_params)
      kernel -> Catalog.update_kernel(kernel, kernel_params)
    end
    |> case do
      {:ok, _kernel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kernel saved.")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp parse_array(params, field) do
    case params[field] do
      val when is_binary(val) ->
        list = val |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
        Map.put(params, field, list)

      _ ->
        params
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6"><%= @page_title %></h1>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <div>
          <label class="block text-sm text-zinc-400 mb-1">Name</label>
          <.input field={@form[:name]} type="text" placeholder="e.g. AITER FP8 MLA Decode" />
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">File Name</label>
          <.input field={@form[:file_name]} type="text" placeholder="e.g. aiter_mla_mi300_fp8_decode.cuh" />
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">Source URL</label>
          <.input field={@form[:source_url]} type="text" placeholder="GitHub permalink" />
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">Source Project</label>
          <.input field={@form[:source_project]} type="text" placeholder="e.g. AITER" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm text-zinc-400 mb-1">Language</label>
            <.input field={@form[:language]} type="text" placeholder="e.g. HIP, CUDA, Triton" />
          </div>
          <div>
            <label class="block text-sm text-zinc-400 mb-1">Algorithm</label>
            <.input field={@form[:algorithm]} type="text" placeholder="e.g. attention_mla_decode" />
          </div>
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">Hardware (comma-separated)</label>
          <.input field={@form[:hardware]} type="text" placeholder="e.g. MI300X, MI350X" value={array_to_string(@form[:hardware].value)} />
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">Techniques (comma-separated)</label>
          <.input field={@form[:techniques]} type="text" placeholder="e.g. MFMA, FP8, split-KV" value={array_to_string(@form[:techniques].value)} />
        </div>

        <div>
          <label class="block text-sm text-zinc-400 mb-1">Notes</label>
          <.input field={@form[:notes]} type="textarea" placeholder="Free-form notes" />
        </div>

        <div class="flex gap-4 pt-4">
          <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
            Save Kernel
          </button>
          <.link navigate={~p"/"} class="text-zinc-400 hover:text-white px-4 py-2">Cancel</.link>
        </div>
      </.form>
    </div>
    """
  end

  defp array_to_string(val) when is_list(val), do: Enum.join(val, ", ")
  defp array_to_string(val), do: val
end
