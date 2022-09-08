defmodule Prag.Desks.Desk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "desks" do
    field :name, :string
    field :photo_url, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(desk, attrs) do
    desk
    |> cast(attrs, [:name, :photo_url])
    |> validate_required([:name, :photo_url])
  end
end
