defmodule PragWeb.SerachLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp store_card(store), do: "#store-#{store.id}"

  def create_store(attrs) do
    {:ok, store} =
      attrs
      # these fields are irrelevant for tests:
      |> Enum.into(%{
        street: "street",
        phone_number: "phone",
        city: "city",
        open: true,
        hours: "hours"
      })
      |> Prag.Stores.create_store()

    store
  end

  test "a zip search shall reply with a valid store", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/search")

    # add stores to the test database

    store_1 = create_store(%{name: "store 1", zip: "80204"})
    store_2 = create_store(%{name: "store 2", zip: "80204"})
    store_3 = create_store(%{name: "store 3", zip: "80204"})
    store_4 = create_store(%{name: "store 4", zip: "80204"})

    # Prag.Stores.list_stores()
    # |> Enum.each(&IO.puts("[#{&1.id}] name: #{&1.name}, zip: #{&1.zip}"))

    assert has_element?(view, "#zip-search")

    view
    |> form("#zip-search", %{zip: "80204"})
    |> render_submit()

    # open_browser(view)

    assert has_element?(view, store_card(store_1)), "not maching with #{store_card(store_1)}"
    assert has_element?(view, store_card(store_2)), "not maching with #{store_card(store_2)}"
    assert has_element?(view, store_card(store_3)), "not maching with #{store_card(store_3)}"
    assert has_element?(view, store_card(store_4)), "not maching with #{store_card(store_4)}"
  end

  test "a not matching zip shall report no stores message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/search")

    # add stores to the test database

    _store_1 = create_store(%{name: "store 1", zip: "80204"})
    _store_2 = create_store(%{name: "store 2", zip: "80204"})
    _store_3 = create_store(%{name: "store 3", zip: "80204"})
    _store_4 = create_store(%{name: "store 4", zip: "80204"})

    assert has_element?(view, "#zip-search")

    view
    |> form("#zip-search", %{zip: "80000"})
    |> render_submit()

    # open_browser(view)

    assert has_element?(view, "p", "No stores matching")
  end

end
