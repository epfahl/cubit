defmodule Cubit.Measure do
  require Decimal
  alias Cubit.Measure
  alias Cubit.Helpers
  alias Cubit.Unit

  defstruct [:value, :unit]

  @type unit :: atom
  @type t :: %Measure{
          value: Decimal.t(),
          unit: Unit.t()
        }

  @doc """
  Create a new measure from a unit and a value.
  """
  @spec new(Unit.t() | t, number | Decimal.t()) :: t
  def new(%Unit{} = unit, value),
    do: %Cubit.Measure{
      unit: unit,
      value: Helpers.to_decimal(value)
    }

  def new(%Measure{value: v} = m, value),
    do: %{m | value: Decimal.mult(v, Helpers.to_decimal(value))}

  @doc """
  Given a measure, return its value as a float.
  """
  @spec to_float(t) :: float()
  def to_float(%Measure{value: v}), do: Decimal.to_float(v)

  @doc """
  Convert a measure to a new unit.
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
  the new scale to 1.
  """
  @spec from_unit(Unit.t()) :: t()
  def from_unit(%Unit{dim: d, scale: s}), do: new(Unit.new(d, 1), s)

  @doc """
  Add two measures with the the same unit.

  An exception is raised is the units do not match.
  """
  @spec add(t, t) :: t
  def add(%Measure{} = m1, %Measure{} = m2), do: op_or_raise(m1, m2, &Decimal.add/2)

  @doc """
  Subtract two measures with the the same unit.

  An exception is raised is the units do not match.
  """
  @spec subtract(t, t) :: t
  def subtract(%Measure{} = m1, %Measure{} = m2), do: op_or_raise(m1, m2, &Decimal.sub/2)

  @doc """
  Raise a measure to an integer power.
  """
  @spec pow(t, integer) :: t
  def pow(%Measure{unit: u}, 0), do: new(Unit.pow(u, 0), 1)

  def pow(%Measure{unit: u, value: v}, exp) when is_integer(exp),
    do: new(Unit.pow(u, exp), Helpers.decimal_pow(v, exp))

  @doc """
  Multiply a measure by another measure or a number.

  When multiplying two measures, the new unit will be the product of the units
  of the input measures.
  """
  @spec multiply(t, t) :: t
  def multiply(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: new(Unit.multiply(u1, u2), Decimal.mult(v1, v2))

  @spec multiply(number | Decimal.t(), t) :: t
  def multiply(num, %Measure{value: v} = m) when is_number(num) or Decimal.is_decimal(num),
    do: %{m | value: Decimal.mult(v, Helpers.to_decimal(num))}

  @spec multiply(t, number | Decimal.t()) :: t
  def multiply(%Measure{value: v} = m, num) when is_number(num) or Decimal.is_decimal(num),
    do: %{m | value: Decimal.mult(v, Helpers.to_decimal(num))}

  @spec divide(t, t) :: t
  def divide(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: new(Unit.divide(u1, u2), Decimal.div(v1, v2))

  @spec divide(number | Decimal.t(), t) :: t
  def divide(num, %Measure{} = m) when is_number(num) or Decimal.is_decimal(num),
    do: multiply(num, pow(m, -1))

  @spec divide(number | Decimal.t(), t) :: t
  def divide(%Measure{value: v} = m, num) when is_number(num) or Decimal.is_decimal(num),
    do: %{m | value: Decimal.div(v, Helpers.to_decimal(num))}

  @spec equal?(t, t) :: boolean
  def equal?(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}),
    do: Unit.equal?(u1, u2) and Decimal.equal?(v1, v2)

  @spec op_or_raise(t, t, (Decimal.t(), Decimal.t() -> Decimal.t())) :: t
  defp op_or_raise(%Measure{unit: u1, value: v1}, %Measure{unit: u2, value: v2}, op) do
    if Unit.equal?(u1, u2) do
      new(u1, op.(v1, v2))
    else
      raise ArgumentError, message: "Units must be equal for this operation."
    end
  end
end
