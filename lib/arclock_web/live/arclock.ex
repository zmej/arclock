defmodule ArclockWeb.Arclock do

  use Phoenix.LiveView

  require Logger

  alias Arclock.Display

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{shift: "--", timer: "---"})}
  end

  def handle_event("set_ab_shift", _, socket) do
    {:noreply, update(socket, :shift, &set_ab_shift/1)}
  end

  def handle_event("set_cd_shift", _, socket) do
    {:noreply, update(socket, :shift, &set_cd_shift/1)}
  end

  def handle_event("set_no_shift", _, socket) do
    {:noreply, update(socket, :shift, &set_no_shift/1)}
  end

  def handle_event("start", _, socket) do
    {:noreply, start(socket)}
  end

  def handle_event("stop", _, socket) do
    {:noreply, stop(socket)}
  end

  def handle_event("set_timer_30", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 30 end)}
  end

  def handle_event("set_timer_40", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 40 end)}
  end

  def handle_event("set_timer_60", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 60 end)}
  end

  def handle_event("set_timer_80", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 80 end)}
  end

  def handle_event("set_timer_90", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 90 end)}
  end

  def handle_event("set_timer_120", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 120 end)}
  end

  def handle_event("set_timer_180", _, socket) do
    {:noreply, update(socket, :timer, fn _ -> 180 end)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <div><h1>ŘADA: <%= @shift %></h1></div>
      <div><h1>DÉLKA SADY: <%= @timer %> sekund</h1></div>

      <div>
         <h2>Řízení řad</h2>
         <button phx-click="set_ab_shift">Řada AB</button>
         <button phx-click="set_cd_shift">Řada CD</button>
         <button phx-click="set_no_shift">Žádná řada</button>
      </div>

      <div>
        <h2>Řízení časovače</h2>
        <button phx-click="start">Start</button>
        <button phx-click="stop">Stop</button>
      </div>

      <div>
        <h2>Nastavení délky sady</h2>
        <h3>Jednotlivci</h3>
        <button phx-click="set_timer_90">Sada 3 šípy (90)</button>
        <button phx-click="set_timer_180">Sada 6 šípů (180)</button>
        <button phx-click="set_timer_30">Rozstřel 1 šíp (30)</button>
      </div>

      <div>
        <h3>Družstva</h3>
        <button phx-click="set_timer_120">Sada 6 šípů (120)</button>
        <button phx-click="set_timer_60">Rozstřel 3 šípy (60)</button>
      </div>

      <div>
        <h3>Smíšená družstva</h3>
        <button phx-click="set_timer_80">Sada 4 šípy (80)</button>
        <button phx-click="set_timer_40">Rozstřel 2 šípy (40)</button>
      </div>

    </div>
    """
  end

  defp set_ab_shift(_value) do
    Display.set_ab_shift()
    "AB"
  end
    
  defp set_cd_shift(_value) do
    Display.set_cd_shift()
    "CD"
  end

  defp set_no_shift(_value) do
    Display.set_no_shift()
    "--"
  end

  defp start(socket) do
    time = socket.assigns.timer

    if is_integer(time) do
      Display.start_countdown(time)
    else
      Logger.warn("Timer value #{time} is not an integer")
    end
 
    socket
  end

  defp stop(socket) do
    Display.stop_countdown()
    socket
  end
end
