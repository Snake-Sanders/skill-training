defmodule PragWeb.LiveHelpers do
  use Phoenix.LiveView
  alias Prag.Accounts

  def assign_current_user(socket, session) do
    # assign_new will call get_use* only if the :current_user is not set
    # this reduce the DB querries from 3 to 2.
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(session["user_token"])
    end)
  end
end
