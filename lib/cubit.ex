defmodule Cubit do
  @readme "README.md"
  @external_resource @readme
  @moduledoc_readme @readme
                    |> File.read!()
                    |> String.split("<!-- END HEADER -->")
                    |> Enum.fetch!(1)
                    |> String.trim()

  @moduledoc """
  #{@moduledoc_readme}
  """

  alias Cubit.Dimension
  alias Cubit.Measure
  alias Cubit.Unit

  @type base_name :: atom | binary
  @type numeric :: number | Decimal.t()
  @type exp :: integer | Ratio.t()
  @type dum :: Dimension.t() | Unit.t() | Measure.t()

  @doc """
  Create a new base dimension.

  ## Examples

      iex> dimension(:length)
      #Dimension<length^1>
  """
  @spec dimension(base_name) :: Dimension.t()
  def dimension(name) when is_atom(name) or is_binary(name), do: Dimension.new(name)

  @doc """
  Create a unit from a dimension and a positive scale factor.

  ## Examples

      iex>  dimension(:length) |> unit(1)
      #Unit<1 #Dimension<length^1>>
  """
  @spec unit(Dimension.t(), numeric) :: Unit.t()
  def unit(dim, scale), do: Unit.new(dim, scale)

  @doc """
  Create a new measure from a unit and a quantity.

  ## Examples

      iex> dimension(:length) |> unit(1) |> measure(3.14)
      #Meausure<3.14 #Unit<1 #Dimension<length^1>>>
  """
  @spec measure(Unit.t(), numeric) :: Measure.t()
  def measure(unit, quantity), do: Measure.new(unit, quantity)

  @doc """
  Raise a dimension, unit, or measure to an integer or rational power.

  ## Examples

      iex> cubic_meter = dimension(:length) |> unit(1) |> pow(3)
      #Unit<1 #Dimension<length^3>>
      iex> vol = cubic_meter |> measure(8)
      #Meausure<8 #Unit<1 #Dimension<length^3>>>
      iex> pow(vol, ratio(1, 3))
      #Meausure<2 #Unit<1 #Dimension<length^1>>>
  """
  @spec pow(Dimension.t(), exp) :: Dimension.t()
  @spec pow(Unit.t(), exp) :: Unit.t()
  @spec pow(Measure.t(), exp) :: Measure.t()
  def pow(%Dimension{} = x, exp), do: Dimension.pow(x, exp)
  def pow(%Unit{} = x, exp), do: Unit.pow(x, exp)
  def pow(%Measure{} = x, exp), do: Measure.pow(x, exp)

  @doc """
  Multiply two dimensions, units, or measures.

  ## Examples

      iex> meter = dimension(:length) |> unit(1)
      iex> kilometer = meter |> multiply(1000)
      iex> kilometer |> measure(3.14)
      #Meausure<3.14 #Unit<1E+3 #Dimension<length^1>>>
  """
  @spec multiply(Dimension.t(), Dimension.t()) :: Dimension.t()
  @spec multiply(Unit.t(), Unit.t()) :: Unit.t()
  @spec multiply(Measure.t(), Measure.t()) :: Measure.t()
  def multiply(%Dimension{} = x1, %Dimension{} = x2), do: Dimension.multiply(x1, x2)
  def multiply(%Unit{} = x1, x2), do: Unit.multiply(x1, x2)
  def multiply(%Measure{} = x1, x2), do: Measure.multiply(x1, x2)

  @doc """
  Divide two dimensions, units, or measures.

  ## Examples

      iex> meter = dimension(:length) |> unit(1)
      iex> second = dimension(:time) |> unit(1)
      iex> divide(meter, second)
      #Unit<1 #Dimension<length^1 time^-1>>
  """
  @spec divide(Dimension.t(), Dimension.t()) :: Dimension.t()
  @spec divide(Unit.t(), Unit.t()) :: Unit.t()
  @spec divide(Measure.t(), Measure.t()) :: Measure.t()
  def divide(%Dimension{} = x1, x2), do: Dimension.divide(x1, x2)
  def divide(%Unit{} = x1, x2), do: Unit.divide(x1, x2)
  def divide(%Measure{} = x1, x2), do: Measure.divide(x1, x2)

  @doc """
  Test if two dimensions, units, or measures are equivalent.

  ## Examples

      iex> meter =  dimension(:length) |> unit(1)
      iex> cubic_meter = meter |> pow(3)
      iex> vol = cubic_meter |> measure(8)
      iex> equal?(vol |> pow(ratio(1, 3)), measure(meter, 2))
      true
  """
  @spec equal?(Dimension.t(), Dimension.t()) :: boolean
  @spec equal?(Unit.t(), Unit.t()) :: boolean
  @spec equal?(Measure.t(), Measure.t()) :: boolean
  def equal?(%Dimension{} = x1, %Dimension{} = x2), do: Dimension.equal?(x1, x2)
  def equal?(%Unit{} = x1, %Unit{} = x2), do: Unit.equal?(x1, x2)
  def equal?(%Measure{} = x1, %Measure{} = x2), do: Measure.equal?(x1, x2)

  @doc """
  Add two measures.
  """
  @spec add(Measure.t(), Measure.t()) :: {:ok, Measure.t()} | :error
  def add(%Measure{} = x1, %Measure{} = x2), do: Measure.add(x1, x2)

  @doc """
  Subtract two measures.
  """
  @spec subtract(Measure.t(), Measure.t()) :: {:ok, Measure.t()} | :error
  def subtract(%Measure{} = x1, %Measure{} = x2), do: Measure.subtract(x1, x2)

  @doc """
  An alias for `Ratio.new(num, den)`.
  """
  @spec ratio(integer, non_neg_integer()) :: Ratio.t()
  def ratio(num, den) when is_integer(num) and is_integer(den), do: Ratio.new(num, den)
end
