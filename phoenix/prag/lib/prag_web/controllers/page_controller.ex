defmodule PragWeb.PageController do
  use PragWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
