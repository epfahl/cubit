defmodule Cubit.Unit do
  @moduledoc """
  """

  require Decimal

  alias Cubit.Unit
  alias Cubit.Dimension
  alias Cubit.Helpers

  defstruct [:dim, :scale]

  @type t :: %Unit{
          dim: Dimension.t(),
          scale: Decimal.t()
        }
  @typep unit :: number | Decimal.t() | t

  @doc """
  Create a new unit from a dimension and a scale.
  """
  @spec new(Dimension.t() | t, number | Decimal.t()) :: t
  def new(%Dimension{} = d, scale), do: %Unit{dim: d, scale: Helpers.to_decimal(scale)}

  @doc """
  Return the relative of two units as a `Decimal`.
  """
  @spec relative_scale(Unit.t(), Unit.t()) :: Decimal.t()
  def relative_scale(%Unit{dim: d_from, scale: s_from}, %Unit{dim: d_to, scale: s_to}),
    do: fun_or_raise(d_from, d_to, fn -> Decimal.div(s_from, s_to) end)

  @doc """
  Raise a unit to an integer power.
  """
  @spec pow(t, integer) :: t
  def pow(%Unit{}, 0), do: new(Dimension.new([]), 1)

  def pow(%Unit{dim: d, scale: s}, exp) when is_integer(exp),
    do: new(Dimension.pow(d, exp), Helpers.decimal_pow(s, exp))

  @doc """
  Multiply two units, a unit and a number, or two numbers, and return the
  resulting unit.

  A number is treated as a dimensionless unit.
  """
  @spec multiply(unit, unit) :: t
  def multiply(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: new(Dimension.multiply(d1, d2), Decimal.mult(s1, s2))

  def multiply(u1, u2), do: multiply(to_unit(u1), to_unit(u2))

  @doc """
  Divide two measures, a unit by a number, a number by a unit, or two
  numbers, and return the resulting unit.

  A number is treated as a dimensionless unit.
  """
  @spec divide(unit, unit) :: t
  def divide(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: new(Dimension.divide(d1, d2), Decimal.div(s1, s2))

  def divide(u1, u2), do: divide(to_unit(u1), to_unit(u2))

  @doc """
  Return `true` if two units have equal dimensions and scales, and `false`
  otherwise.
  """
  @spec equal?(t, t) :: boolean()
  def equal?(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: Dimension.equal?(d1, d2) and Decimal.equal?(s1, s2)

  @doc """
  Compare the scales of two units with the same dimension and return `:lt`
  (less than), `:gt` (greater than), or `:eq` (equal).
  """
  @spec compare(t, t) :: :lt | :gt | :eq
  def compare(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: fun_or_raise(d1, d2, fn -> Decimal.compare(s1, s2) end)

  @spec to_unit(unit) :: t
  defp to_unit(%Unit{} = u), do: u

  defp to_unit(u) when is_number(u) or Decimal.is_decimal(u),
    do: Dimension.new([]) |> new(u)

  @spec fun_or_raise(Dimension.t(), Dimension.t(), (-> any)) :: any
  defp fun_or_raise(d1, d2, fun) do
    if Dimension.equal?(d1, d2) do
      fun.()
    else
      raise ArgumentError, message: "when comparing unit, the dimensions must be equal"
    end
  end
end
