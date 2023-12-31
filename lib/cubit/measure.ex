defmodule Cubit.Measure do
  @moduledoc """
  Create and operate on measures.

  A measure is a way to express an amount of something, and is composed of a
  unit and a quantity.
  """

  import Ratio, only: [is_rational: 1]
  alias Cubit.Dimension
  alias Cubit.Helpers
  import Cubit.Guards, only: [is_numeric: 1]
  alias Cubit.Measure
  alias Cubit.Unit

  defstruct [:quantity, :unit]

  @type unit :: atom
  @type t :: %Measure{
          quantity: Decimal.t(),
          unit: Unit.t()
        }

  @doc """
  Create a new measure from a unit and a quantity.

  ## Examples

      iex> alias Cubit.Dimension
      iex> alias Cubit.Unit
      iex> Dimension.new(:length) |> Unit.new(1) |> Measure.new(3.14)
      #Meausure<3.14 #Unit<1 #Dimension<length^1>>>
  """
  @spec new(Unit.t(), number | Decimal.t()) :: t
  def new(%Unit{} = unit, quantity) when is_numeric(quantity) do
    {:ok, quantity} = Decimal.cast(quantity)
    %Cubit.Measure{unit: unit, quantity: Decimal.normalize(quantity)}
  end

  @doc """
  Raise a measure to an integer or rational power.

  ## Examples

      iex> alias Cubit.Dimension
      iex> alias Cubit.Unit
      iex> meter = Dimension.new(:length) |> Unit.new(1)
      iex> vol = new(meter, 2) |> pow(3)
      #Meausure<8 #Unit<1 #Dimension<length^3>>>
      iex> pow(vol, Ratio.new(1, 3))
      #Meausure<2 #Unit<1 #Dimension<length^1>>>
  """
  @spec pow(t, integer | Ratio.t()) :: t
  def pow(%Measure{unit: unit, quantity: quantity}, exp)
      when is_integer(exp) or is_rational(exp) do
    if exp == 0 or exp == Ratio.new(0) do
      new(Unit.pow(unit, 0), 1)
    else
      new(Unit.pow(unit, exp), Helpers.decimal_pow(quantity, exp))
    end
  end

  @doc """
  Multiply two measures or a measure and a number.

  A number is treated as a measure with a dimensionless measure.
  """
  @spec multiply(t, t | number | Decimal.t()) :: t
  def multiply(
        %Measure{unit: u1, quantity: q1},
        %Measure{unit: u2, quantity: q2}
      ) do
    new(Unit.multiply(u1, u2), Decimal.mult(q1, q2))
  end

  def multiply(%Measure{} = measure, num) when is_numeric(num) do
    multiply(measure, numeric_to_measure(num))
  end

  @doc """
  Divide two measures or a measure and a number.

  A number is treated as a dimensionless measure.
  """
  @spec divide(t, t | number | Decimal.t()) :: t
  def divide(
        %Measure{unit: u1, quantity: q1},
        %Measure{unit: u2, quantity: q2}
      ) do
    new(Unit.divide(u1, u2), Decimal.div(q1, q2))
  end

  def divide(%Measure{} = measure, num) when is_numeric(num) do
    divide(measure, numeric_to_measure(num))
  end

  @doc """
  Add two measures with the the same dimensions.

  This returns `{:ok, measure}` if the dimensions match, and `:error` if the
  dimensions are different.
  """
  @spec add(t, t) :: {:ok, t} | :error
  def add(%Measure{unit: u1} = m1, %Measure{unit: u2} = m2) do
    if Dimension.equal?(u1.dim, u2.dim) do
      m1_norm = normalize(m1)
      m2_norm = normalize(m2)

      {:ok,
       new(
         m1_norm.unit,
         Decimal.add(m1_norm.quantity, m2_norm.quantity)
       )}
    else
      :error
    end
  end

  @doc """
  Subtract two measures with the the same dimensions.

  This returns `{:ok, measure}` if the dimensions match, and `:error` if the dimensions
  are different.
  """
  @spec subtract(t, t) :: {:ok, t} | :error
  def subtract(%Measure{unit: u1} = m1, %Measure{unit: u2} = m2) do
    if Dimension.equal?(u1.dim, u2.dim) do
      m1_norm = normalize(m1)
      m2_norm = normalize(m2)

      {:ok,
       new(
         m1_norm.unit,
         Decimal.sub(m1_norm.quantity, m2_norm.quantity)
       )}
    else
      :error
    end
  end

  @doc """
  Test if two measures are equivalent.

  Returns `true` if the two measures have equal units and quantities, and `false`
  otherwise.
  """
  @spec equal?(t, t) :: boolean
  def equal?(%Measure{unit: u1, quantity: v1}, %Measure{unit: u2, quantity: v2}) do
    Unit.equal?(u1, u2) and Decimal.equal?(v1, v2)
  end

  @doc """
  Compare the quantities of two measures with the same units.

  This returns `{:ok, :lt | :gt | :eq}` if the units match, and `:error`
  if the units are different.
  """
  @spec compare(t, t) :: {:ok, :lt | :gt | :eq} | :error
  def compare(%Measure{unit: u1, quantity: v1}, %Measure{unit: u2, quantity: v2}) do
    if Unit.equal?(u1, u2) do
      {:ok, Decimal.compare(v1, v2)}
    else
      :error
    end
  end

  @doc """
  Convert a measure to a new unit with the same dimension.

  An exception is raised is the units do not match.
  """
  @spec convert(t, Unit.t()) :: {:ok, t} | :error
  def convert(%Measure{unit: unit_from, quantity: quantity}, unit_to) do
    with {:ok, scale} <- Unit.relative_scale(unit_from, unit_to) do
      {:ok, new(unit_to, Decimal.mult(quantity, scale))}
    end
  end

  @doc """
  Cast a measure to a unit by multiplying the unit and the quantity to create
  a new unit scale.
  """
  @spec to_unit(t) :: Unit.t()
  def to_unit(%Measure{unit: u, quantity: q}), do: Unit.multiply(u, q)

  @doc """
  Cast a unit to a measure by promoting the scale to a quantity and setting
  the new unit scale to 1.
  """
  @spec from_unit(Unit.t()) :: t()
  def from_unit(%Unit{dim: d, scale: s}), do: new(Unit.new(d, 1), s)

  @doc """
  Normalize a measure by converting it to base unit with a scale of 1.
  """
  @spec normalize(t) :: t
  def normalize(%Measure{unit: u, quantity: q}), do: u |> from_unit() |> multiply(q)

  @spec numeric_to_measure(number | Decimal.t()) :: t
  defp numeric_to_measure(num) when is_numeric(num) do
    Dimension.new([]) |> Unit.new(1) |> new(num)
  end
end

defimpl Inspect, for: Cubit.Measure do
  alias Cubit.Measure

  def inspect(%Measure{quantity: quantity, unit: unit}, opts) do
    "#Meausure<#{parse_quantity(quantity)} #{Inspect.Cubit.Unit.inspect(unit, opts)}>"
  end

  defp parse_quantity(quantity) do
    Decimal.to_string(quantity)
  end
end
