defmodule Prag.PizzaOrdersTest do
  use Prag.DataCase

  alias Prag.PizzaOrders

  describe "pizza_orders" do
    alias Prag.PizzaOrders.PizzaOrder

    import Prag.PizzaOrdersFixtures

    @invalid_attrs %{pizza: nil, username: nil}

    test "list_pizza_orders/0 returns all pizza_orders" do
      pizza_order = pizza_order_fixture()
      assert PizzaOrders.list_pizza_orders() == [pizza_order]
    end

    test "get_pizza_order!/1 returns the pizza_order with given id" do
      pizza_order = pizza_order_fixture()
      assert PizzaOrders.get_pizza_order!(pizza_order.id) == pizza_order
    end

    test "create_pizza_order/1 with valid data creates a pizza_order" do
      valid_attrs = %{pizza: "some pizza", username: "some username"}

      assert {:ok, %PizzaOrder{} = pizza_order} = PizzaOrders.create_pizza_order(valid_attrs)
      assert pizza_order.pizza == "some pizza"
      assert pizza_order.username == "some username"
    end

    test "create_pizza_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PizzaOrders.create_pizza_order(@invalid_attrs)
    end

    test "update_pizza_order/2 with valid data updates the pizza_order" do
      pizza_order = pizza_order_fixture()
      update_attrs = %{pizza: "some updated pizza", username: "some updated username"}

      assert {:ok, %PizzaOrder{} = pizza_order} = PizzaOrders.update_pizza_order(pizza_order, update_attrs)
      assert pizza_order.pizza == "some updated pizza"
      assert pizza_order.username == "some updated username"
    end

    test "update_pizza_order/2 with invalid data returns error changeset" do
      pizza_order = pizza_order_fixture()
      assert {:error, %Ecto.Changeset{}} = PizzaOrders.update_pizza_order(pizza_order, @invalid_attrs)
      assert pizza_order == PizzaOrders.get_pizza_order!(pizza_order.id)
    end

    test "delete_pizza_order/1 deletes the pizza_order" do
      pizza_order = pizza_order_fixture()
      assert {:ok, %PizzaOrder{}} = PizzaOrders.delete_pizza_order(pizza_order)
      assert_raise Ecto.NoResultsError, fn -> PizzaOrders.get_pizza_order!(pizza_order.id) end
    end

    test "change_pizza_order/1 returns a pizza_order changeset" do
      pizza_order = pizza_order_fixture()
      assert %Ecto.Changeset{} = PizzaOrders.change_pizza_order(pizza_order)
    end
  end
end
