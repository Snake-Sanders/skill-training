defmodule Prag.DesksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prag.Desks` context.
  """

  @doc """
  Generate a desk.
  """
  def desk_fixture(attrs \\ %{}) do
    {:ok, desk} =
      attrs
      |> Enum.into(%{
        name: "some name",
        photo_url: []
      })
      |> Prag.Desks.create_desk()

    desk
  end
end
