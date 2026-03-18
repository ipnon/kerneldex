defmodule Kerneldex.Accounts do
  import Ecto.Query
  alias Kerneldex.Repo
  alias Kerneldex.Accounts.{User, ApiToken}

  # --- Users ---

  def get_user!(id), do: Repo.get!(User, id)

  def get_or_create_user_from_github(github_user) do
    attrs = %{
      github_id: github_user["sub"],
      github_login: github_user["preferred_username"],
      github_avatar: github_user["picture"],
      email: github_user["email"]
    }

    case Repo.get_by(User, github_id: attrs.github_id) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      user ->
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end

  # --- API Tokens ---

  def list_tokens_for_user(user_id) do
    ApiToken
    |> where([t], t.user_id == ^user_id)
    |> where([t], is_nil(t.revoked_at))
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
  end

  def create_api_token(user_id, label \\ nil) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    token_hash = hash_token(raw_token)

    %ApiToken{user_id: user_id, token_hash: token_hash, label: label, raw_token: raw_token}
    |> Repo.insert()
  end

  def verify_api_token(raw_token) do
    token_hash = hash_token(raw_token)

    ApiToken
    |> where([t], t.token_hash == ^token_hash and is_nil(t.revoked_at))
    |> preload(:user)
    |> Repo.one()
    |> case do
      nil ->
        nil

      token ->
        token
        |> Ecto.Changeset.change(last_used_at: DateTime.utc_now())
        |> Repo.update()

        token.user
    end
  end

  def revoke_token(token_id, user_id) do
    ApiToken
    |> where([t], t.id == ^token_id and t.user_id == ^user_id)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      token ->
        token
        |> Ecto.Changeset.change(revoked_at: DateTime.utc_now())
        |> Repo.update()
    end
  end

  defp hash_token(raw_token) do
    :crypto.hash(:sha256, raw_token)
  end
end
