defmodule KerneldexWeb.TokenLive.Index do
  use KerneldexWeb, :live_view

  alias Kerneldex.Accounts

  on_mount {KerneldexWeb.Plugs.Auth, :require_auth}

  @impl true
  def mount(_params, _session, socket) do
    tokens = Accounts.list_tokens_for_user(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(:tokens, tokens)
     |> assign(:new_token, nil)
     |> assign(:label, "")}
  end

  @impl true
  def handle_event("create_token", %{"label" => label}, socket) do
    label = if label == "", do: nil, else: label

    case Accounts.create_api_token(socket.assigns.current_user.id, label) do
      {:ok, token} ->
        tokens = Accounts.list_tokens_for_user(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> assign(:tokens, tokens)
         |> assign(:new_token, token.raw_token)
         |> assign(:label, "")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to create token")}
    end
  end

  @impl true
  def handle_event("revoke_token", %{"id" => id}, socket) do
    Accounts.revoke_token(String.to_integer(id), socket.assigns.current_user.id)
    tokens = Accounts.list_tokens_for_user(socket.assigns.current_user.id)

    {:noreply, assign(socket, :tokens, tokens)}
  end

  @impl true
  def handle_event("dismiss_token", _params, socket) do
    {:noreply, assign(socket, :new_token, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6">API Tokens</h1>

      <%= if @new_token do %>
        <div class="bg-green-900/50 border border-green-700 rounded-lg p-4 mb-6">
          <p class="text-green-300 text-sm mb-2">Token created. Copy it now — you won't see it again.</p>
          <code class="block bg-zinc-900 text-green-400 p-3 rounded font-mono text-sm break-all select-all">
            <%= @new_token %>
          </code>
          <button phx-click="dismiss_token" class="text-zinc-400 hover:text-white text-sm mt-2">Dismiss</button>
        </div>
      <% end %>

      <form phx-submit="create_token" class="flex gap-3 mb-8">
        <input
          type="text"
          name="label"
          value={@label}
          placeholder="Token label (optional)"
          class="bg-zinc-800 border border-zinc-700 rounded-lg px-3 py-2 text-white placeholder-zinc-500 flex-1"
        />
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          Create Token
        </button>
      </form>

      <div class="space-y-3">
        <%= for token <- @tokens do %>
          <div class="flex items-center justify-between bg-zinc-800 rounded-lg px-4 py-3">
            <div>
              <span class="text-white"><%= token.label || "Unlabeled" %></span>
              <span class="text-zinc-500 text-sm ml-3">
                Created <%= Calendar.strftime(token.inserted_at, "%Y-%m-%d") %>
              </span>
              <%= if token.last_used_at do %>
                <span class="text-zinc-500 text-sm ml-2">
                  Last used <%= Calendar.strftime(token.last_used_at, "%Y-%m-%d") %>
                </span>
              <% end %>
            </div>
            <button
              phx-click="revoke_token"
              phx-value-id={token.id}
              class="text-red-400 hover:text-red-300 text-sm"
              data-confirm="Revoke this token?"
            >
              Revoke
            </button>
          </div>
        <% end %>

        <%= if @tokens == [] do %>
          <p class="text-zinc-500">No active tokens. Create one to use the API.</p>
        <% end %>
      </div>

      <div class="mt-8">
        <.link navigate={~p"/"} class="text-zinc-400 hover:text-white">&larr; Back to kernels</.link>
      </div>
    </div>
    """
  end
end
