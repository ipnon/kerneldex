defmodule KerneldexWeb.Plugs.Auth do
  @moduledoc "Loads current_user from session into assigns."
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        assign(conn, :current_user, nil)

      user_id ->
        user = Kerneldex.Accounts.get_user!(user_id)
        assign(conn, :current_user, user)
    end
  end

  def on_mount(:default, _params, session, socket) do
    case session["user_id"] do
      nil ->
        {:cont, Phoenix.Component.assign(socket, :current_user, nil)}

      user_id ->
        user = Kerneldex.Accounts.get_user!(user_id)
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    end
  end

  def on_mount(:require_auth, _params, session, socket) do
    case session["user_id"] do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/")}

      user_id ->
        user = Kerneldex.Accounts.get_user!(user_id)
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    end
  end
end
