defmodule PragWeb.TopSecretLive do
  use PragWeb, :live_view

  # alias Prag.Accounts
  import PragWeb.LiveHelpers

  def mount(_params, session, socket) do
    IO.puts("++ mount topsecret")
    {:ok, assign_current_user(socket, session)}
  end

  def render(assigns) do
    ~H"""
    <h1>Top Secret</h1>
    <div id="top-secret">
    <%= if @current_user do %>
    <img src="images/spy.svg">
    <div class="mission">
      <h2>Your Mission</h2>
      <h3><%= pat_id(@current_user) %></h3>
      <p>
      (should you choose to accept it)
      </p>
      <p>
      is detailed below...
      </p>
    </div>
    <% else %>
      <h2>Invalid user</h2>
    <% end %>
    </div>
    """
  end

  defp pat_id(user) do
    user.id
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end
end
