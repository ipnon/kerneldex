defmodule KerneldexWeb.Router do
  use KerneldexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KerneldexWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug KerneldexWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug KerneldexWeb.Plugs.ApiAuth
  end

  pipeline :api_write do
    plug :require_api_token
  end

  defp require_api_token(conn, _opts) do
    KerneldexWeb.Plugs.ApiAuth.require_token(conn, [])
  end

  scope "/", KerneldexWeb do
    pipe_through :browser

    live "/", KernelLive.Index
    live "/kernels/new", KernelLive.Form
    live "/kernels/:id/edit", KernelLive.Form
    live "/tokens", TokenLive.Index
  end

  scope "/auth", KerneldexWeb do
    pipe_through :browser

    get "/github", AuthController, :request
    get "/github/callback", AuthController, :callback
    delete "/logout", AuthController, :logout
  end

  # Public API — reads
  scope "/api", KerneldexWeb.Api do
    pipe_through :api

    get "/kernels", KernelController, :index
    get "/kernels/:id", KernelController, :show
  end

  # Authenticated API — writes
  scope "/api", KerneldexWeb.Api do
    pipe_through [:api, :api_write]

    post "/kernels", KernelController, :create
    put "/kernels/:id", KernelController, :update
    delete "/kernels/:id", KernelController, :delete
  end
end
