defmodule KerneldexWeb.KernelLive.Index do
  use KerneldexWeb, :live_view

  alias Kerneldex.Catalog

  on_mount {KerneldexWeb.Plugs.Auth, :default}

  @impl true
  def mount(params, _session, socket) do
    filters = extract_filters(params)

    socket =
      socket
      |> assign(:filters, filters)
      |> assign(:algorithms, Catalog.distinct_values(:algorithm))
      |> assign(:languages, Catalog.distinct_values(:language))
      |> assign(:sources, Catalog.distinct_values(:source_project))
      |> assign(:hardwares, Catalog.distinct_hardware_values())
      |> assign_kernels()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = extract_filters(params)

    socket =
      socket
      |> assign(:filters, filters)
      |> assign_kernels()

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", params, socket) do
    filters = %{
      algorithm: params["algorithm"],
      language: params["language"],
      source_project: params["source_project"],
      hardware: params["hardware"],
      search: params["search"]
    }

    query_params =
      filters
      |> Enum.reject(fn {_k, v} -> v in [nil, ""] end)
      |> Map.new()

    {:noreply, push_patch(socket, to: ~p"/?#{query_params}")}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/")}
  end

  defp extract_filters(params) do
    %{
      algorithm: params["algorithm"],
      language: params["language"],
      source_project: params["source_project"],
      hardware: params["hardware"],
      search: params["search"]
    }
  end

  defp assign_kernels(socket) do
    kernels = Catalog.list_kernels(socket.assigns.filters)
    assign(socket, :kernels, kernels)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold">KernelDex</h1>
          <p class="opacity-60 mt-1">Community-curated GPU kernel index</p>
        </div>
        <div class="flex items-center gap-4">
          <%= if @current_user do %>
            <.link navigate={~p"/kernels/new"} class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
              Submit Kernel
            </.link>
            <.link navigate={~p"/tokens"} class="opacity-60 hover:opacity-100">
              API Tokens
            </.link>
            <span class="opacity-60">
              <%= @current_user.github_login %>
            </span>
            <.link href={~p"/auth/logout"} method="delete" class="opacity-50 hover:text-red-400 text-sm">
              Logout
            </.link>
          <% else %>
            <.link href={~p"/auth/github"} class="bg-base-200 px-4 py-2 rounded-lg hover:bg-base-300">
              Sign in with GitHub
            </.link>
          <% end %>
        </div>
      </div>

      <form phx-change="filter" phx-submit="filter" class="grid grid-cols-2 md:grid-cols-6 gap-3 mb-6">
        <input
          type="text"
          name="search"
          value={@filters.search}
          placeholder="Search kernels..."
          phx-debounce="300"
          class="bg-base-200 border border-base-300 rounded-lg px-3 py-2 placeholder-base-content/50 col-span-2 md:col-span-1"
        />

        <select name="algorithm" class="bg-base-200 border border-base-300 rounded-lg px-3 py-2">
          <option value="">All Algorithms</option>
          <%= for algo <- @algorithms do %>
            <option value={algo} selected={@filters.algorithm == algo}><%= algo %></option>
          <% end %>
        </select>

        <select name="language" class="bg-base-200 border border-base-300 rounded-lg px-3 py-2">
          <option value="">All Languages</option>
          <%= for lang <- @languages do %>
            <option value={lang} selected={@filters.language == lang}><%= lang %></option>
          <% end %>
        </select>

        <select name="hardware" class="bg-base-200 border border-base-300 rounded-lg px-3 py-2">
          <option value="">All Hardware</option>
          <%= for hw <- @hardwares do %>
            <option value={hw} selected={@filters.hardware == hw}><%= hw %></option>
          <% end %>
        </select>

        <select name="source_project" class="bg-base-200 border border-base-300 rounded-lg px-3 py-2">
          <option value="">All Sources</option>
          <%= for src <- @sources do %>
            <option value={src} selected={@filters.source_project == src}><%= src %></option>
          <% end %>
        </select>

        <button type="button" phx-click="clear_filters" class="opacity-60 hover:opacity-100 text-sm">
          Clear
        </button>
      </form>

      <div class="opacity-60 text-sm mb-4">
        <%= length(@kernels) %> kernels
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="border-b border-base-300 opacity-60 text-sm">
            <tr>
              <th class="pb-3 pr-4">File</th>
              <th class="pb-3 pr-4">Algorithm</th>
              <th class="pb-3 pr-4">Language</th>
              <th class="pb-3 pr-4">Hardware</th>
              <th class="pb-3">Source</th>
            </tr>
          </thead>
          <tbody class="text-sm">
            <%= for kernel <- @kernels do %>
              <tr class="border-b border-base-200 hover:bg-base-200/50">
                <td class="py-3 pr-4">
                  <a href={kernel.source_url} target="_blank" class="text-blue-400 hover:text-blue-300 font-mono font-medium">
                    <%= kernel.file_name %>
                  </a>
                </td>
                <td class="py-3 pr-4"><%= kernel.algorithm %></td>
                <td class="py-3 pr-4">
                  <span class="bg-base-200 px-2 py-0.5 rounded text-xs"><%= kernel.language %></span>
                </td>
                <td class="py-3 pr-4">
                  <%= for hw <- kernel.hardware do %>
                    <span class="bg-base-200 px-2 py-0.5 rounded text-xs mr-1"><%= hw %></span>
                  <% end %>
                </td>
                <td class="py-3 pr-4 opacity-60 text-xs">
                  <%= if kernel.source_project do %>
                    <span><%= kernel.source_project %></span>
                  <% else %>
                    <span class="truncate max-w-[200px] inline-block align-bottom"><%= kernel.source_url %></span>
                  <% end %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
