defmodule Prag.BoatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prag.Boats` context.
  """

  @doc """
  Generate a boat.
  """
  def boat_fixture(attrs \\ %{}) do
    {:ok, boat} =
      attrs
      |> Enum.into(%{
        image: "some image",
        model: "some model",
        price: "some price",
        type: "some type"
      })
      |> Prag.Boats.create_boat()

    boat
  end
end
