defmodule PragWeb.ServerFormComponent do
  use PragWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.form let={f} for={@changeset}
              phx-submit="save"
              phx-change="validate">
          <div class="field">
            <%= label f, :name %>
            <%= text_input f, :name, phx_debounce: "blur" %>
            <%= error_tag f, :name %>
          </div>

          <div class="field">
            <%= label f, :framework %>
            <%= text_input f, :framework, phx_debounce: "blur" %>
            <%= error_tag f, :framework %>
          </div>

          <div class="field">
            <%= label f, :size, "Size (MB)" %>
            <%= number_input f, :size, phx_debounce: "blur" %>
            <%= error_tag f, :size %>
          </div>

          <div class="field">
            <%= label f, :git_repo, "Git Repo" %>
            <%= text_input f, :git_repo, phx_debounce: "blur" %>
            <%= error_tag f, :git_repo %>
          </div>

          <%= submit("Save", phx_disable_with: "Saving...") %>
          <%= live_patch "Cancel",
            to: Routes.live_path(@socket, PragWeb.ServersLive),
            class: "cancel"
          %>
      </.form>
    </div>
    """
  end

end
