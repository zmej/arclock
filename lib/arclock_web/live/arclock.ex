defmodule ArclockWeb.Arclock do

  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :display, "--")}
  end

  def handle_event("set_ab", _, socket) do
    {:noreply, update(socket, :display, fn(_) -> "AB" end)}
  end

  def handle_event("set_cd", _, socket) do
    {:noreply, update(socket, :display, fn(_) -> "CD" end)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1><%= @display %>
      <button phx-click="set_ab">Řada AB</button>
      <button phx-click="set_cd">Řada CD</button>
    </div>
    """
  end
end
