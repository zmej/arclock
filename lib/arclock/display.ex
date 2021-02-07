defmodule Arclock.Display do
  
  use GenServer

  alias Arclock.Digit

  require Logger

  @tick_interval 1000
  @default_shift :ab

  #====================================
  # API
 
  @doc """
  Example:
  {:ok, pid} = Arclock.Display.start_link
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :display)
  end

  def set_ab(pid) do
    GenServer.cast(pid, {:set_shift, :ab})
  end

  def get_shift(pid) do
    GenServer.call(pid, :get_shift)
  end

  def set_cd(pid) do
    GenServer.cast(pid, {:set_shift, :cd})
  end
  
  def start_countdown(pid, value) do
    GenServer.cast(pid, {:start_countdown, value})
  end

  def stop_countdown(pid) do
    GenServer.cast(pid, :stop_countdown)
  end

  def get_counter(pid) do
    GenServer.call(pid, :get_counter)
  end

  def is_running?(pid) do
    GenServer.call(pid, :get_running)
  end

  #====================================
  # Callbacks

  @impl true
  def init(_) do
    Digit.start_link(:ones, :b)
    Digit.start_link(:tens, :a)
    Digit.start_link(:hundreds, :blank)
    
    state = %{
      counter: 0,
      shift: @default_shift,
      running: false
    }

    display_shift(@default_shift)
    Logger.info("Display: initialization completed")
    {:ok, state}
  end

  @impl true
  def handle_cast({:set_shift, shift}, state) do
    if state.counter == 0 do
      display_shift(shift)
    end

    {:noreply, %{state | shift: shift}}
  end

  def handle_cast({:start_countdown, _value}, %{running: true} = state) do
    Logger.warn("Display: cannot start new countdown while previous one is still running")
    {:noreply, state}    
  end

  def handle_cast({:start_countdown, value}, state) do
    display_counter(value)
    Logger.info("Display: started countdown from #{value}")
    tick()
    {:noreply, %{state | counter: value, running: true}}
  end

  def handle_cast(:stop_countdown, %{running: :false} = state) do
    Logger.info("Display: countdown already stopped")
    {:noreply, state}
  end

  def handle_cast(:stop_countdown, state) do
    display_shift(state.shift)
    Logger.info("Display: countdown stopped, current counter value is #{state.counter}")
    {:noreply, %{state | counter: 0, running: false}}
  end

  @impl true
  def handle_info(:tick, %{running: false} = state) do
    # When counting was stopped by user but there is palnned tick in the mailbox
    {:noreply, state}
  end

  def handle_info(:tick, %{counter: 0} = state) do
    display_shift(state.shift)
    Logger.info("Display: counter elapsed")
    {:noreply, %{state | running: false}}
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

  def handle_call(:get_running, _from, state) do
    {:reply, state.running, state}
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