defmodule PragWeb.TopSecretLiveTest do
  use PragWeb.ConnCase, async: true

  alias Prag.AccountsFixtures

  import Phoenix.LiveViewTest

  test "logged user can see topsecret", %{conn: conn} do
    user = create_user("test@test.com", "test-password")

    {:ok, view, _html} =
      conn
      |> log_in_user(user)
      |> live("/topsecret")

    assert render(view) =~ "Your Mission"
  end

  test "anonymous gets a flash whrn navigating to topsecret", %{conn: conn} do
    {:error,
     {:redirect,
      %{
        flash: %{"error" => message},
        to: redirect_to
      }}} = live(conn, "/topsecret")

    assert redirect_to == "/users/log_in"
    assert message =~ "You must log in to access this page."
  end

  defp create_user(email, pass) do
    %{
      email: email,
      password: pass
    }
    |> AccountsFixtures.user_fixture()
  end
end
