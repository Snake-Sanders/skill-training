defmodule Prag.VolunteersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prag.Volunteers` context.
  """

  @doc """
  Generate a volunteer.
  """
  def volunteer_fixture(attrs \\ %{}) do
    {:ok, volunteer} =
      attrs
      |> Enum.into(%{
        checked_out: true,
        name: "some name",
        phone: "777 123 4444"
      })
      |> Prag.Volunteers.create_volunteer()

    volunteer
  end
end
