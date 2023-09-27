defmodule Cubit.Standards do
  @moduledoc """
  Standard dimensions and units.
  """

  alias Cubit.Dimension, as: D
  alias Cubit.Unit, as: U

  # Non-dimensional constants
  def pi, do: Decimal.new("3.141592653589793238462643383279503")
  def euler_e, do: Decimal.new("2.718281828459045235360287471352663")

  # Dimensions
  def len, do: D.new(:length)
  def time, do: D.new(:time)
  def mass, do: D.new(:mass)
  def angle, do: D.new(:angle)
  def speed, do: D.divide(len(), time())
  def acceleration, do: D.divide(speed(), time())
  def frequency, do: D.pow(time(), -1)
  def momentum, do: D.multiply(mass(), speed())
  def energy, do: D.multiply(momentum(), speed())
  def force, do: D.divide(momentum(), time())

  # Lengths
  def meter, do: U.new(len(), 1)
  def millimeter, do: U.multiply(meter(), 0.001)
  def centimeter, do: U.multiply(millimeter(), 10)
  def kilometer, do: U.multiply(meter(), 1000)
  def inch, do: U.multiply(centimeter(), 2.54)
  def foot, do: U.multiply(inch(), 12)
  def yard, do: U.multiply(foot(), 3)
  def mile, do: U.multiply(foot(), 5280)
  def light_second, do: U.multiply(meter(), 299_792_458)
  def light_minute, do: U.multiply(light_second(), 60)
  def light_year, do: U.new(len(), 9_460_730_472_580_800)
  def astronomical_unit, do: U.new(len(), 149_597_870_700)
  def parsec, do: U.divide(U.multiply(648_000, astronomical_unit()), pi())

  # Times
  def second, do: U.new(time(), 1)
  def minute, do: U.multiply(second(), 60)
  def hour, do: U.multiply(minute(), 60)
  def day, do: U.multiply(hour(), 24)
  def year, do: U.multiply(day(), 365)

  # Masses
  def kilogram, do: U.new(mass(), 1)
  def gram, do: U.divide(kilogram(), 1000)

  # Angles
  def radian, do: U.new(angle(), 1)
  def degree, do: U.multiply(radian(), 0.01745329251)
  def arcsec, do: U.divide(degree(), 3600)
  def arcmin, do: U.multiply(arcsec(), 60)

  # Forces
  def newton, do: nil
  def pound, do: nil
end
