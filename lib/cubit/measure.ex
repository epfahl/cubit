defmodule Cubit.Measure do
  @moduledoc """
  """

  require Decimal
  alias Cubit.Dimension
  alias Cubit.Measure
  alias Cubit.Helpers
  alias Cubit.Unit
  alias Cubit.Measure

  defstruct [:value, :unit]

  @type unit :: atom
  @type t :: %Measure{
          value: Decimal.t(),
          unit: Unit.t()
        }
  @typep measure :: number | Decimal.t() | t

  @doc """
  Create a new measure from a unit and a value.
  """
  @spec new(Unit.t() | t, number | Decimal.t()) :: t
  def new(%Unit{} = unit, value),
    do: %Cubit.Measure{
      unit: unit,
      value: Helpers.to_decimal(value)
    }

  @doc """
  Return the value of a measurement as a float.
  """
  @spec to_float(t) :: float()
  def to_float(%Measure{value: v}), do: Decimal.to_float(v)

  @doc """
  Convert a measure to a new unit with the same dimension.

  An exception is raised is the units do not match.
  """
  @spec convert(t, Unit.t()) :: t
  def convert(%Measure{unit: u_from, value: v}, u_to),
    do: new(u_to, Decimal.mult(v, Unit.relative_scale(u_from, u_to)))

  @doc """
  Cast a measure to a unit by multiplying the unit and the value.
  """
  @spec to_unit(t) :: Unit.t()
  def to_unit(%Measure{unit: u, value: v}), do: Unit.multiply(u, v)

  @doc """
  Cast a unit to a measure by promoting the scale to a value and setting
  the new unit scale to 1.
  """
  @spec from_unit(Unit.t()) :: t()
  def from_unit(%Unit{dim: d, scale: s}), do: new(Unit.new(d, 1), s)

  @doc """
  Add two measures with the the same units.

  An exception is raised is the units do not match.
  """
  @spec add(t, t) :: t
  def add(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: fun_or_raise(u1, u2, fn -> new(u1, Decimal.add(v1, v2)) end)

  @doc """
  Subtract two measures with the the same units.

  An exception is raised is the units do not match.
  """
  @spec subtract(t, t) :: t
  def subtract(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: fun_or_raise(u1, u2, fn -> new(u1, Decimal.sub(v1, v2)) end)

  @doc """
  Raise a measure to an integer power.
  """
  @spec pow(t, integer) :: t
  def pow(%Measure{unit: u}, 0), do: u |> Unit.pow(0) |> new(1)

  def pow(%Measure{unit: u, value: v}, exp) when is_integer(exp),
    do: u |> Unit.pow(exp) |> new(Helpers.decimal_pow(v, exp))

  @doc """
  Multiply two measures, a measure and a number, or two numbers, and return the
  resulting measure.

  A number is treated as a measure with a dimensionless unit.
  """
  @spec multiply(measure, measure) :: t
  def multiply(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: new(Unit.multiply(u1, u2), Decimal.mult(v1, v2))

  def multiply(m1, m2), do: multiply(to_measure(m1), to_measure(m2))

  @doc """
  Divide two measures, a measure by a number, a number by a measure, or two
  numbers, and return the resulting measure.

  A number is treated as a measure with a dimensionless unit.
  """
  @spec divide(measure, measure) :: t
  def divide(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: new(Unit.divide(u1, u2), Decimal.div(v1, v2))

  def divide(m1, m2), do: divide(to_measure(m1), to_measure(m2))

  @doc """
  Return `true` if two measures have equal units and values, and `false`
  otherwise.
  """
  @spec equal?(t, t) :: boolean
  def equal?(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: Unit.equal?(u1, u2) and Decimal.equal?(v1, v2)

  @doc """
  Compare the values of two measures with the same dimension and return `:lt`
  (less than), `:gt` (greater than), or `:eq` (equal).
  """
  @spec compare(t, t) :: :lt | :gt | :eq
  def compare(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: fun_or_raise(u1, u2, fn -> Decimal.compare(v1, v2) end)

  @spec to_measure(number | Decimal.t() | t) :: t
  defp to_measure(%Measure{} = m), do: m

  defp to_measure(m) when is_number(m) or Decimal.is_decimal(m),
    do: Dimension.new([]) |> Unit.new(1) |> new(m)

  @spec fun_or_raise(Unit.t(), Unit.t(), (-> any)) :: any
  defp fun_or_raise(u1, u2, fun) do
    if Unit.equal?(u1, u2) do
      fun.()
    else
      raise ArgumentError, message: "when comparing measures, the units must be equal"
    end
  end
end
