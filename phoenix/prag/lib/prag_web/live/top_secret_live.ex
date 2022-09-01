defmodule PragWeb.TopSecretLive do
  use PragWeb, :live_view
  alias Prag.Accounts

  def mount(_params, session, socket) do
    # assign_new will call get_use* only if the :current_user is not set
    # this reduce the DB querries from 3 to 2.
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(session["user_token"])
      end)

    {:ok, socket}
    # {:ok, assign_current_user(socket, session)}
  end

  def render(assigns) do
    ~H"""
    <h1>Top Secret</h1>
    <div id="top-secret">
      <img src="images/spy.svg">
      <div class="mission">
        <h2>Your Mission</h2>
        <h3>00<%= @current_user.id %></h3>
        <p>
          (should you choose to accept it)
        </p>
        <p>
          is detailed below...
        </p>
      </div>
    </div>
    """
  end
end
