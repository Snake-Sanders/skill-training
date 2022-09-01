defmodule PragWeb.InfiniteScrollLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders more orders when user scrolls to bottom", %{conn: conn} do
    create_orders()

    {:ok, view, _html} = live(conn, "/infinite-scroll")

    # there should be now 10 orders listed
    assert render(view) |> number_of_orders() == 10

    # this will call the phx-hook that is in the footer,
    # then the hook will be handled by the client App.js & Hooks.js
    # which then will push an event "load-more" to the server
    view
    |> element("#footer")
    |> render_hook("load-more", %{})

    assert render(view) |> number_of_orders() == 11

  end

  defp number_of_orders(html) do
    html |> :binary. matches("Test Pizza") |> length()
  end

  defp create_orders() do
    for i <- 1..11 do
      {:ok, _order} =
        Prag.PizzaOrders.create_pizza_order(%{
          username: "Test User #{i}",
          pizza: "Test Pizza #{i}"
        })
    end
  end

end
