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

  @spec new(Dimension.t() | t, number | Decimal.t()) :: t
  def new(%Dimension{} = d, scale), do: %Unit{dim: d, scale: Helpers.to_decimal(scale)}

  @spec relative_scale(Unit.t(), Unit.t()) :: Decimal.t()
  def relative_scale(%Unit{dim: d_from, scale: s_from}, %Unit{dim: d_to, scale: s_to}) do
    if Dimension.equal?(d_from, d_to) do
      Decimal.div(s_from, s_to)
    else
      raise ArgumentError, message: "When comparing units, the dimensions must be equal."
    end
  end

  @spec pow(t, integer) :: t
  def pow(%Unit{}, 0), do: new(Dimension.new([]), 1)

  def pow(%Unit{dim: d, scale: s}, exp) when is_integer(exp),
    do: new(Dimension.pow(d, exp), Helpers.decimal_pow(s, exp))

  @spec multiply(t, t) :: t
  def multiply(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: new(Dimension.multiply(d1, d2), Decimal.mult(s1, s2))

  @spec multiply(number | Decimal.t(), t) :: t
  def multiply(num, %Unit{scale: s} = u) when is_number(num) or Decimal.is_decimal(num),
    do: %{u | scale: Decimal.mult(s, Helpers.to_decimal(num))}

  @spec multiply(t, number | Decimal.t()) :: t
  def multiply(%Unit{scale: s} = u, num) when is_number(num) or Decimal.is_decimal(num),
    do: %{u | scale: Decimal.mult(s, Helpers.to_decimal(num))}

  @spec divide(t, t) :: t
  def divide(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: new(Dimension.divide(d1, d2), Decimal.div(s1, s2))

  @spec divide(number | Decimal.t(), t) :: t
  def divide(num, %Unit{} = u) when is_number(num) or Decimal.is_decimal(num),
    do: multiply(num, pow(u, -1))

  @spec divide(number | Decimal.t(), t) :: t
  def divide(%Unit{scale: s} = u, num) when is_number(num) or Decimal.is_decimal(num),
    do: %{u | scale: Decimal.div(s, Helpers.to_decimal(num))}

  @spec equal?(t, t) :: boolean()
  def equal?(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}),
    do: Dimension.equal?(d1, d2) and Decimal.equal?(s1, s2)
end
