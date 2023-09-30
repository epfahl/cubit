defmodule Cubit.Dimension do
  @moduledoc """
  """

  alias Cubit.Dimension
  alias Cubit.Base

  defstruct [:dim]

  @type t :: %Dimension{
          dim: Base.t() | [{t, integer}]
        }

  @doc """
  Create either a named base dimension or a composite diemsnion.
  """
  @spec new(Base.base_name() | t | [{t, integer}]) :: t
  def new(dim) when is_atom(dim), do: %Dimension{dim: Base.new(dim)}

  def new(dim) when is_list(dim) do
    base_dim =
      dim
      |> to_base(1)
      |> consolidate_dim()

    %Dimension{dim: base_dim}
  end

  @spec to_base(t | [{t, integer}], integer) :: [{t, integer}]
  defp to_base(dims, exp) when is_list(dims),
    do: Enum.flat_map(dims, fn {d, e} -> to_base(d, exp * e) end)

  defp to_base(%Dimension{dim: %Base{}} = d, exp), do: [{d, exp}]
  defp to_base(%Dimension{dim: dim}, exp), do: to_base(dim, exp)

  @spec consolidate_dim([{t, integer}]) :: [{t, integer}]
  defp consolidate_dim(dim) do
    dim
    |> Enum.reduce(%{}, fn {d, e}, acc -> Map.update(acc, d, e, &(&1 + e)) end)
    |> Map.to_list()
    |> Enum.reject(fn {_d, e} -> e == 0 end)
  end

  @doc """
  Raise a dimension to an integer power.
  """
  @spec pow(t, integer) :: t
  def pow(%Dimension{}, 0), do: new([])
  def pow(%Dimension{} = d, exp) when is_integer(exp), do: to_dim(d) |> apply_exp(exp) |> new()

  @spec apply_exp([{t, integer}], integer) :: [{t, integer}]
  defp apply_exp(dim, exp), do: Enum.map(dim, fn {d, e} -> {d, e * exp} end)

  @doc """
  Mutiply two dimenions.
  """
  @spec multiply(t, t) :: t
  def multiply(%Dimension{} = d1, %Dimension{} = d2),
    do: Enum.concat(to_dim(d1), to_dim(d2)) |> new()

  @doc """
  Divide two measures.
  """
  @spec divide(t, t) :: t
  def divide(%Dimension{} = d1, %Dimension{} = d2), do: d2 |> pow(-1) |> multiply(d1)

  @doc """
  Return `true` if two dimensions have the same set of base dimensions, and
  `false` otherwise.
  """
  @spec equal?(t, t) :: boolean
  def equal?(%Dimension{} = d1, %Dimension{} = d2), do: MapSet.equal?(to_set(d1), to_set(d2))

  @spec to_set(t) :: MapSet.t({t, integer()})
  defp to_set(%Dimension{dim: %Base{}} = d), do: d |> to_dim() |> MapSet.new()
  defp to_set(%Dimension{dim: dim}), do: new(dim) |> to_dim() |> MapSet.new()

  @spec to_dim(t) :: [{t, integer}]
  defp to_dim(%Dimension{dim: %Base{}} = d), do: [{d, 1}]
  defp to_dim(%Dimension{dim: dim}) when is_list(dim), do: dim
end
