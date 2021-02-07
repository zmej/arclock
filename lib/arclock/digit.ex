defmodule Arclock.Digit do
  @moduledoc """
  Drives GPIO outputs for 7-segment decoder of digits of given order.
  """    

  use GenServer
  alias Circuits.GPIO

  require Logger

  @initial_value 0

  #====================================
  # API

  @doc """
  Example:
  {:ok, pid} = Digit.start_link(:ones, :blank)
  """  
  def start_link(magnitude, default) do
    GenServer.start_link(__MODULE__, {magnitude, default}, name: magnitude)
  end

  @doc """
  Example:
  Digit.set(pid, :a)
  """
  def set(pid, digit) do
    GenServer.cast(pid, {:set_digit, digit})
  end

  #====================================
  # Callbacks

  @doc """
  Initializes outputs. 
  Then sets outputs to the default value.
  """
  @impl true
  def init({magnitude, default}) do
    pin_numbers = Application.get_env(:arclock, magnitude)
    digits = Application.get_env(:arclock, :digits)
    pins = pin_numbers 
      |> Enum.map(fn {output, pin_num} -> 
                    {:ok, pin} = GPIO.open(pin_num, :output, initial_value: @initial_value)
                    {output, pin}
                  end)
      |> Enum.into(%{})

    state = %{magnitude: magnitude, pins: pins, digits: digits, digit: default}
    set_digit(default, state)

    Logger.info("Digit: #{magnitude} initialized on pins #{inspect(pin_numbers)} with value #{default}")
    {:ok, state}
  end

  @doc """
  Sends command to set the digit to the decoder.
  """
  @impl true
  def handle_cast({:set_digit, digit}, state) do
    if digit != state.digit do
      set_digit(digit, state)
      Logger.info("Digit: #{state.magnitude} set to #{digit} encoding #{inspect(state.digits[digit])}")
      {:noreply, %{state | digit: digit}}
    else
      {:noreply, state}
    end
  end

  #====================================
  # Privates
  
  defp set_digit(digit, state) do
    Enum.each(state.digits[digit], 
      fn {output, level} -> GPIO.write(state.pins[output], level) end)
  end

end
