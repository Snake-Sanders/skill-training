defmodule PragWeb.SalesController do
  use PragWeb, :controller

  def index(conn, _params) do
    # fetch top sellers and recent orders
    render(conn, "index.html")
  end
end
