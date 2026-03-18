defmodule KerneldexWeb.AuthController do
  use KerneldexWeb, :controller

  @github_config [
    client_id: {System, :get_env, ["GITHUB_CLIENT_ID"]},
    client_secret: {System, :get_env, ["GITHUB_CLIENT_SECRET"]},
    redirect_uri: {System, :get_env, ["GITHUB_REDIRECT_URI"]}
  ]

  def request(conn, _params) do
    config = resolve_config()

    {:ok, %{url: url}} = Assent.Strategy.Github.authorize_url(config)

    conn
    |> put_session(:assent_state, url |> URI.parse() |> Map.get(:query) |> URI.decode_query() |> Map.get("state"))
    |> redirect(external: url)
  end

  def callback(conn, params) do
    config = resolve_config()

    # Merge the session state for CSRF verification
    params = Map.put(params, "state", get_session(conn, :assent_state))

    case Assent.Strategy.Github.callback(config, params) do
      {:ok, %{user: github_user, token: _token}} ->
        case Kerneldex.Accounts.get_or_create_user_from_github(github_user) do
          {:ok, user} ->
            conn
            |> delete_session(:assent_state)
            |> put_session(:user_id, user.id)
            |> redirect(to: ~p"/")

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Failed to create account")
            |> redirect(to: ~p"/")
        end

      {:error, _error} ->
        conn
        |> put_flash(:error, "GitHub authentication failed")
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  defp resolve_config do
    Enum.map(@github_config, fn
      {key, {mod, fun, args}} -> {key, apply(mod, fun, args)}
      pair -> pair
    end)
  end
end
