defmodule Cubit.Dimension do
  @moduledoc """
  Create and operate on dimensions.
  """

  import Ratio, only: [is_rational: 1]
  alias Cubit.Dimension
  alias Cubit.Dimension.Base

  defstruct [:components]

  @type component :: {Base.t(), Ratio.t()}
  @type t :: %Dimension{components: Base.t() | [component()]}

  @doc """
  Create either a named base dimension or a composite dimension.

  ## Examples

      iex> l = new(:length)
      #Dimension<length^1>
      iex> t = new(:time)
      #Dimension<time^1>
      iex> new([{l, 1}, {t, -1}])
      #Dimension<length^1 time^-1>
  """
  @spec new(Base.name() | [{t, integer | Ratio.t()}]) :: t
  def new(name_or_comps) when is_atom(name_or_comps) or is_binary(name_or_comps) do
    %Dimension{components: Base.new(name_or_comps)}
  end

  def new([_ | _] = name_or_comps), do: %Dimension{components: to_components(name_or_comps, 1)}
  def new([]), do: %Dimension{components: []}

  @doc """
  Raise a dimension to an integer or rational power.

  ## Examples

      iex> l = new(:length)
      #Dimension<length^1>
      iex> vol = pow(l, 3)
      #Dimension<length^3>
      iex> pow(vol, Ratio.new(1, 3))
      #Dimension<length^1>
  """
  @spec pow(t, integer | Ratio.t()) :: t
  def pow(%Dimension{} = dim, exp) when is_integer(exp) or is_rational(exp) do
    if exp == 0 or exp == Ratio.new(0) do
      new([])
    else
      new([{dim, exp}])
    end
  end

  @doc """
  Mutiply two dimenions.

  ## Examples

      iex> l = new(:length)
      #Dimension<length^1>
      iex> multiply(l, l)
      #Dimension<length^2>
  """
  @spec multiply(t, t) :: t
  def multiply(%Dimension{} = dim1, %Dimension{} = dim2),
    do: new([{dim1, 1}, {dim2, 1}])

  @doc """
  Divide two measures.

  ## Examples

      iex> l = new(:length)
      #Dimension<length^1>
      iex> t = new(:time)
      #Dimension<time^1>
      iex> divide(l, t)
      #Dimension<length^1 time^-1>
  """
  @spec divide(t, t) :: t
  def divide(%Dimension{} = dim1, %Dimension{} = dim2), do: dim2 |> pow(-1) |> multiply(dim1)

  @doc """
  Test if two dimensions are equivalent.

  Returns `true` if the two dimensions have the same base components, and
  `false` otherwise. A base dimension is equlivalent to a dimension whose only
  component is that base dimension with an expoenent of 1.

  ## Examples

      iex> l = new(:length)
      #Dimension<length^1>
      iex> t = new(:time)
      #Dimension<time^1>
      iex> equal?(l, t)
      false
      iex> equal?(l, new([{l, 1}]))
      true
  """
  @spec equal?(t, t) :: boolean
  def equal?(%Dimension{} = dim1, %Dimension{} = dim2) do
    [set1, set2] =
      Enum.map([dim1, dim2], fn dim ->
        dim |> to_components(1) |> MapSet.new()
      end)

    MapSet.equal?(set1, set2)
  end

  # Reduce a dimension or dimension-exponent pairs to a list of base
  # components with the given exponent. Each base dimension will appear only
  # once, and base dimensions with exponent 0 are removed.
  @spec to_components(t | [{t, integer | Ratio.t()}], integer | Ratio.t()) :: [component()]
  defp to_components(%Dimension{components: %Base{}} = dim, exp), do: [{dim, Ratio.new(exp)}]
  defp to_components(%Dimension{components: comps}, exp), do: to_components(comps, exp)

  defp to_components(dims, exp) when is_list(dims) do
    exp = Ratio.new(exp)

    dims
    |> Enum.flat_map(fn {d, e} -> to_components(d, Ratio.mult(exp, e)) end)
    |> Enum.reduce(%{}, fn {d, e}, acc -> Map.update(acc, d, e, &Ratio.add(&1, e)) end)
    |> Enum.reject(fn {_d, e} -> Ratio.equal?(e, 0) end)
  end
end

defimpl Inspect, for: Cubit.Dimension do
  alias Cubit.Dimension.Base
  alias Cubit.Dimension

  def inspect(%Dimension{components: comps}, _opts) do
    components_str =
      case comps do
        %Base{name: name} ->
          "#{to_string(name)}^1"

        dims when is_list(dims) ->
          dims
          |> Enum.map_join(" ", fn {%Dimension{components: %Base{name: name}}, e} ->
            "#{to_string(name)}^#{parse_ratio(e)}"
          end)
      end

    "#Dimension<#{components_str}>"
  end

  defp parse_ratio(%Ratio{numerator: n, denominator: 1}), do: "#{n}"
  defp parse_ratio(%Ratio{numerator: n, denominator: d}), do: "#{n}/#{d}"
end
