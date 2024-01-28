defmodule Cubit.Unit do
  @moduledoc """
  Create and operate on units.

  A unit is a standard of measurement, and is composed of a dimension and a
  scale factor. For example, a _meter_ is a unit of length, and a _second_ is a
  unit of time. If _meter_ and _second_ are basic units for measuring length
  and time, then the scale factor in each case is 1. In this system of units,
  a _kilometer_ has a scale factor of 1000, and an _hour_ has a scale factor
  of 3600.
  """

  import Ratio, only: [is_rational: 1]
  import Cubit.Guards, only: [is_numeric: 1, pos_numeric: 1]
  alias Cubit.Dimension
  alias Cubit.Helpers
  alias Cubit.Unit

  defstruct [:dim, :scale, :name]

  @type t :: %Unit{
          dim: Dimension.t(),
          scale: Decimal.t(),
          name: nil | atom
        }
  @type numeric :: number | Decimal.t()

  @doc """
  Create a unit from a dimension and a positive scale factor.

  ## Examples

      iex> alias Cubit.Dimension
      iex>  new(Dimension.new(:length), 1)
      #Unit<1 #Dimension<length^1>>
  """
  @spec new(Dimension.t(), numeric, keyword()) :: t
  def new(%Dimension{} = dim, scale, opts \\ []) when pos_numeric(scale) do
    name = Keyword.get(opts, :name)
    {:ok, scale} = Decimal.cast(scale)
    %Unit{dim: dim, scale: Decimal.normalize(scale), name: name}
  end

  @doc """
  Raise a unit to an integer or rational power.

  ## Examples

      iex> alias Cubit.Dimension
      iex> cubic_meter = Dimension.new(:length) |> new(1) |> pow(3)
      #Unit<1 #Dimension<length^3>>
      iex> pow(cubic_meter, Ratio.new(1, 3))
      #Unit<1 #Dimension<length^1>>
  """
  @spec pow(t, integer | Ratio.t()) :: t
  def pow(%Unit{dim: dim, scale: scale}, exp) when is_integer(exp) or is_rational(exp) do
    if exp == 0 or exp == Ratio.new(0) do
      new(Dimension.new([]), 1)
    else
      new(Dimension.pow(dim, exp), Helpers.decimal_pow(scale, exp))
    end
  end

  @doc """
  Multiply two units or a unit and a number.

  The first argument must be a unit. A number is treated as a dimensionless unit.

  ## Examples

      iex> alias Cubit.Dimension
      iex> meter = new(Dimension.new(:length), 1)
      #Unit<1 #Dimension<length^1>>
      iex> multiply(meter, 1000)
      #Unit<1E+3 #Dimension<length^1>>
  """
  @spec multiply(t, t | numeric) :: t
  def multiply(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}) do
    new(Dimension.multiply(d1, d2), Decimal.mult(s1, s2))
  end

  def multiply(%Unit{} = unit, num) when is_numeric(num), do: multiply(unit, numeric_to_unit(num))

  @doc """
  Divide two units or a unit and a number.

  A number or `Decimal` is treated as a dimensionless unit.

  ## Examples

      iex> alias Cubit.Dimension
      iex> l = Dimension.new(:length)
      #Dimension<length^1>
      iex> t = Dimension.new(:time)
      #Dimension<time^1>
      iex> Dimension.divide(l, t) |> new(1)
      #Unit<1 #Dimension<length^1 time^-1>>
  """
  @spec divide(t, t | numeric) :: t
  def divide(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}) do
    new(Dimension.divide(d1, d2), Decimal.div(s1, s2))
  end

  def divide(%Unit{} = unit, num) when is_numeric(num), do: divide(unit, numeric_to_unit(num))

  @doc """
  Test if two units are equivalent.

  Returns `true` if the two units have equal dimensions and scales, and `false`
  otherwise.

  ## Examples

      iex> alias Cubit.Dimension
      iex> l =  Dimension.new(:length)
      #Dimension<length^1>
      iex> decameter = new(l, 10)
      #Unit<1E+1 #Dimension<length^1>>
      iex> equal?(decameter |> divide(10), new(l, 1))
      true
  """
  @spec equal?(t, t) :: boolean()
  def equal?(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}) do
    Dimension.equal?(d1, d2) and Decimal.equal?(s1, s2)
  end

  @doc """
  Compare the scales of two units with the same dimension.

  This returns `{:ok, :lt | :gt | :eq}` if the dimensions match, and `:error`
  if the dimensions are different.

  ## Examples

      iex> alias Cubit.Dimension
      iex> l = Dimension.new(:length)
      #Dimension<length^1>
      iex> t = Dimension.new(:time)
      #Dimension<time^1>
      iex> mps = Dimension.divide(l, t) |> new(1)
      #Unit<1 #Dimension<length^1 time^-1>>
      iex> kps = multiply(mps, 10)
      #Unit<1E+1 #Dimension<length^1 time^-1>>
      iex> compare(kps, mps)
      {:ok, :gt}
  """
  @spec compare(t, t) :: {:ok, :lt | :gt | :eq} | :error
  def compare(%Unit{dim: d1, scale: s1}, %Unit{dim: d2, scale: s2}) do
    if Dimension.equal?(d1, d2) do
      {:ok, Decimal.compare(s1, s2)}
    else
      :error
    end
  end

  @doc """
  Return the relative scale of two units with the same dimension.

  This returns `{:ok, decimal}` if the dimensions match, and `:error` if the
  dimensions are different.

  ## Examples

      iex> alias Cubit.Dimension
      iex> l = Dimension.new(:length)
      #Dimension<length^1>
      iex> t = Dimension.new(:time)
      #Dimension<time^1>
      iex> mps = Dimension.divide(l, t) |> new(1)
      #Unit<1 #Dimension<length^1 time^-1>>
      iex> kps = multiply(mps, 10)
      #Unit<1E+1 #Dimension<length^1 time^-1>>
      iex> relative_scale(kps, mps)
      {:ok, Decimal.new("1E+1")}
  """
  @spec relative_scale(Unit.t(), Unit.t()) :: {:ok, Decimal.t()} | :error
  def relative_scale(%Unit{dim: dim_from, scale: scale_from}, %Unit{dim: dim_to, scale: scale_to}) do
    if Dimension.equal?(dim_from, dim_to) do
      {:ok, Decimal.div(scale_from, scale_to) |> Decimal.normalize()}
    else
      :error
    end
  end

  @spec numeric_to_unit(numeric) :: t
  defp numeric_to_unit(num) when is_numeric(num) do
    new(Dimension.new([]), num)
  end
end

defimpl Inspect, for: Cubit.Unit do
  alias Cubit.Unit

  def inspect(%Unit{scale: scale, dim: dim, name: name}, opts) do
    "#Unit<#{parse_scale(scale)} #{parse_name(name)} #{Inspect.Cubit.Dimension.inspect(dim, opts)}>"
  end

  defp parse_name(name), do: to_string(name)

  defp parse_scale(scale), do: Decimal.to_string(scale)
end
