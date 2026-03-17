defmodule KerneldexWeb.Plugs.ApiAuth do
  @moduledoc "Authenticates API requests via Bearer token."
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %{} = user <- Kerneldex.Accounts.verify_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ -> assign(conn, :current_user, nil)
    end
  end

  def require_token(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.json(%{error: "Valid API token required"})
      |> halt()
    end
  end
end
