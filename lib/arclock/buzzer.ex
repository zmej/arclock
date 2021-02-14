defmodule Arclock.Buzzer do

  alias Circuits.GPIO
  require Logger

  @buzzer_on 1
  @buzzer_off 0
  @loud_time 1000
  @quiet_time 1000

  def init do
    buzzer_pin = Application.get_env(:arclock, :buzzer_pin)
    case GPIO.open(buzzer_pin, :output, initial_value: @buzzer_off) do
      {:ok, pin} -> 
        pin
      {:error, reason} ->
        Logger.error("buzzer pin was not initialized due to #{inspect(reason)}")
        nil
    end
  end

  def prepare(pin) do
    beep(pin)
    quiet()
    beep(pin)
  end

  def start_shooting(pin) do
    beep(pin)
  end

  def stop_shooting(pin) do
    beep(pin)
    quiet()
    beep(pin)
    quiet()
    beep(pin)
  end

  defp beep(pin) do
    GPIO.write(pin, @buzzer_on)
    Process.sleep(@loud_time)
    GPIO.write(pin, @buzzer_off)
  end

  defp quiet() do
    Process.sleep(@quiet_time)
  end

end
