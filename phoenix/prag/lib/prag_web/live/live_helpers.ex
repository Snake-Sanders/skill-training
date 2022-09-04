defmodule PragWeb.LiveHelpers do
  use Phoenix.LiveView
  alias Prag.Accounts

  def assign_current_user(socket, session) do
    # IO.puts("+++ Connected: #{connected?(socket)}")
    # assign_new will call get_use* only if the :current_user is not set
    # this reduce the DB querries from 3 to 2.

    user =
      case Map.has_key?(session, "user_token") do
        false ->
          nil

        true ->
          session["user_token"]
          # |> IO.inspect(lable: "++ THE TOKEN iS OK")
          |> Accounts.get_user_by_session_token()
      end

    # IO.puts("++ Assigning current user #{inspect user} ")
    assign_new(socket, :current_user, fn -> user end)
  end

  def render(assigns) do
    ~H"""
    """
  end
end
