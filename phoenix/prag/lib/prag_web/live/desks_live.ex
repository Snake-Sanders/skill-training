defmodule PragWeb.DesksLive do
  use PragWeb, :live_view

  alias Prag.Desks
  alias Prag.Desks.Desk

  def mount(_param, _session, socket) do
    if connected?(socket), do: Desks.subscribe()

    desks = Desks.list_desks()
    changeset = Desks.change_desk(%Desk{})

    socket =
      assign(socket,
        desks: desks,
        changeset: changeset
      )

    socket =
      allow_upload(
        socket,
        :photo,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 3,
        max_file_size: 3_000_000
      )

    {:ok, socket, temporary_assigns: [desks: []]}
  end

  def handle_event("save", %{"desk" => params}, socket) do
    # now the images are already uploaded
    # 1. copy temp files
    urls =
      consume_uploaded_entries(socket, :photo, fn meta, entry ->
        # processes each upload file, the files are cleared on func exit
        dest = Path.join("priv/static/uploads", filename(entry))
        File.cp!(meta.path, dest)
        Routes.static_path(socket, "/uploads/#{filename(entry)}")
      end)

    # desk = %Desk{photo_url: urls}
    params = Map.merge(params, %{"photo_url" => urls})

    case Desks.create_desk(params) do
      {:ok, _desk} ->
        changeset = Desks.change_desk(%Desk{})
        {:noreply, assign(socket, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"desk" => params}, socket) do
    changeset =
      %Desk{}
      |> Desks.change_desk(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def handle_info({:desk_created, desk}, socket) do
    {:noreply, update(socket, :desks, fn desks -> [desk | desks] end)}
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end
end
