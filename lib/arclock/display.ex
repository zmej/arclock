defmodule Arclock.Display do
  
  use GenServer

  alias Arclock.Digit
  alias Arclock.Buzzer

  require Logger

  @shooting_preparation_time 10 # seconds
  @tick_interval 1000           # milliseconds
  @default_shift :no_shift

  #====================================
  # API
 
  @doc """
  Example:
  {:ok, pid} = Arclock.Display.start_link
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :display)
  end

  def set_ab_shift do
    GenServer.cast(:display, {:set_shift, :ab})
  end

   def set_cd_shift do
    GenServer.cast(:display, {:set_shift, :cd})
  end

  def set_no_shift do
    GenServer.cast(:display, {:set_shift, :no_shift})
  end

  def get_shift do
    GenServer.call(:display, :get_shift)
  end

  def start_countdown(value) do
    GenServer.cast(:display, {:start_countdown, value})
  end

  def stop_countdown do
    GenServer.cast(:display, :stop_countdown)
  end

  def get_counter do
    GenServer.call(:display, :get_counter)
  end

  #====================================
  # State Description
  # set_length: Required length of set in seconds. 
  # counter: Remaining secods. Decremented by one every second to the zero.
  # shift: Current shift is displayed before or after countdown.
  # countdown_state: :preparation | :shooting | :iddle
  #   :preparation - After judge starts countdown shooters have 10 seconds to enter the shooting line
  #   :shooting - Time for shooting arrows.
  #   :idle - Time between sets.
  # buzzer: Output pin to control buzzer. 

  #====================================
  # Callbacks

  @impl true
  def init(_) do
    Digit.start_link(:ones, :blank)
    Digit.start_link(:tens, :blank)
    Digit.start_link(:hundreds, :blank)
    buzzer = Buzzer.init()    

    state = %{
      set_length: 0,
      counter: 0,
      shift: @default_shift,
      countdown_state: :idle,
      buzzer: buzzer
    }

    display_shift(@default_shift)
    Logger.info("Display: initialization completed")
    {:ok, state}
  end

  @impl true
  def handle_cast({:set_shift, shift}, %{countdown_state: :idle} = state) do
    # Display can be changed only when countdown is not running.
    display_shift(shift)
    {:noreply, %{state | shift: shift}}
  end

  def handle_cast({:set_shift, shift}, state) do
    # When countdown is running then only state is changed. 
    # New shift will be displayed after countdown stop.
    {:noreply, %{state | shift: shift}}
  end

  def handle_cast({:start_countdown, _value}, %{countdown_state: countdown_state} = state) when countdown_state != :idle do
    Logger.warn("Display: cannot start new countdown while previous one is still running")
    {:noreply, state}    
  end

  def handle_cast({:start_countdown, value}, state) do
    Buzzer.prepare_shooting(state.buzzer)
    display_counter(@shooting_preparation_time)
    Logger.info("Display: started countdown from #{value}")
    tick()
    {:noreply, %{state | 
      set_length: value,
      counter: @shooting_preparation_time,
      countdown_state: :preparation}}
  end

  def handle_cast(:stop_countdown, %{countdown_state: :idle} = state) do
    Logger.info("Display: countdown already stopped")
    {:noreply, state}
  end

  def handle_cast(:stop_countdown, state) do
    Buzzer.stop_shooting(state.buzzer)
    display_shift(state.shift)
    Logger.info("Display: countdown stopped, current counter value is #{state.counter}")
    {:noreply, %{state | counter: 0, countdown_state: :idle}}
  end

  @impl true
  def handle_info(:tick, %{countdown_state: :idle} = state) do
    # When counting was stopped by user but there is palnned tick in the mailbox
    {:noreply, state}
  end

  def handle_info(:tick, %{counter: 0, countdown_state: :shooting} = state) do
    Buzzer.stop_shooting(state.buzzer)
    display_shift(state.shift)
    Logger.info("Display: counter elapsed")
    {:noreply, %{state | countdown_state: :idle}}
  end

  def handle_info(:tick, %{counter: 0, countdown_state: :preparation} = state) do
    Buzzer.start_shooting(state.buzzer)
    display_counter(state.set_length)
    tick()
    {:noreply, %{state | countdown_state: :shooting, counter: state.set_length}}
  end

  def handle_info(:tick, state) do
    new_counter = state.counter - 1
    display_counter(new_counter)
    tick()
    {:noreply, %{state | counter: new_counter}}
  end

  @impl true
  def handle_call(:get_counter, _from, %{:counter => counter} = state) do
    {:reply, counter, state}
  end

  def handle_call(:get_shift, _from, %{:shift => shift} = state) do
    {:reply, shift, state}
  end

  #====================================
  # Privates

  defp display_shift(shift) do
    {tens, ones} = split_shift(shift)
    set_display({:blank, tens, ones})
    Logger.info("Display: shift set to #{shift}")
  end

  defp display_counter(counter) do
    counter
    |> split_magnitudes()
    |> remove_leading_zeroes()
    |> set_display()
    Logger.info("Display: counter set to #{counter}")
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  defp set_display({hundreds, tens, ones}) do
    Digit.set(:ones, ones)
    Digit.set(:tens, tens)
    Digit.set(:hundreds, hundreds)
  end

  defp split_shift(:ab), do: {:a, :b}
  defp split_shift(:cd), do: {:c, :d}
  defp split_shift(:no_shift), do: {:dash, :dash}

  def split_magnitudes(number) do
    hundreds = div(number, 100)
    tens = div(rem(number, 100), 10)
    ones = rem(number, 10)
    remove_leading_zeroes({hundreds, tens, ones})
  end

  defp remove_leading_zeroes({0, 0, x}), do: {:blank, :blank, x}
  defp remove_leading_zeroes({0, x, y}), do: {:blank, x, y}
  defp remove_leading_zeroes(x), do: x

end
