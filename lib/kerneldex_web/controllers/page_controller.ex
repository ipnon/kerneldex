defmodule KerneldexWeb.PageController do
  use KerneldexWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
