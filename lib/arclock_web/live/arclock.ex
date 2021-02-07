defmodule ArclockWeb.Arclock do

  use Phoenix.LiveView

  alias Arclock.Display

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :display, "--")}
  end

  def handle_event("set_ab", _, socket) do
    {:noreply, update(socket, :display, &set_ab/1)}
  end

  def handle_event("set_cd", _, socket) do
    {:noreply, update(socket, :display, &set_cd/1)}
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

  defp set_ab(_value) do
    Display.set_ab(:display)
    "AB"
  end
    
  defp set_cd(_value) do
    Display.set_cd(:display)
    "CD"
  end
end
