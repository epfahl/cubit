defmodule Cubit.Standards do
  @moduledoc """
  Standard dimensions and units.

  # TODO: update to use public interface
  """

  # alias Cubit.Dimension, as: D
  # alias Cubit.Unit, as: U

  import Cubit

  # Non-dimensional constants
  def pi, do: Decimal.new("3.141592653589793238462643383279503")
  def euler_e, do: Decimal.new("2.718281828459045235360287471352663")

  # Dimensions
  def len, do: dimension(:length)
  def time, do: dimension(:time)
  def mass, do: dimension(:mass)
  def angle, do: dimension(:angle)
  def speed, do: divide(len(), time())
  def acceleration, do: divide(speed(), time())
  def frequency, do: pow(time(), -1)
  def momentum, do: multiply(mass(), speed())
  def energy, do: multiply(momentum(), speed())
  def force, do: divide(momentum(), time())

  # Length units
  def meter, do: unit(len(), 1)
  def millimeter, do: multiply(meter(), 0.001)
  def centimeter, do: multiply(millimeter(), 10)
  def kilometer, do: multiply(meter(), 1000)
  def inch, do: multiply(centimeter(), 2.54)
  def foot, do: multiply(inch(), 12)
  def yard, do: multiply(foot(), 3)
  def mile, do: multiply(foot(), 5280)
  def light_second, do: multiply(meter(), 299_792_458)
  def light_minute, do: multiply(light_second(), 60)
  def light_year, do: unit(len(), 9_460_730_472_580_800)
  def astronomical_unit, do: unit(len(), 149_597_870_700)
  def parsec, do: divide(multiply(astronomical_unit(), 648_000), pi())

  # Time units
  def second, do: unit(time(), 1)
  def minute, do: multiply(second(), 60)
  def hour, do: multiply(minute(), 60)
  def day, do: multiply(hour(), 24)
  def year, do: multiply(day(), 365)

  # Masses
  def kilogram, do: unit(mass(), 1)
  def gram, do: divide(kilogram(), 1000)

  # Angles
  def radian, do: unit(angle(), 1)
  def degree, do: multiply(radian(), 0.01745329251)
  def arcsec, do: divide(degree(), 3600)
  def arcmin, do: multiply(arcsec(), 60)

  # Forces
  def newton, do: unit(force(), 1)
  def pound, do: multiply(newton(), 4.4482216152605)

  # Volumes
  def liter, do: nil
  def millileter, do: nil
  def teaspoon, do: nil
  def tablespoon, do: nil
  def cup, do: nil
  def fluid_ounce, do: nil
end
