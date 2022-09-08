defmodule Prag.Repo.Migrations.CreateDesks do
  use Ecto.Migration

  def change do
    create table(:desks) do
      add :name, :string
      add :photo_url, {:array, :string}

      timestamps()
    end
  end
end
