defmodule Cubit.Dimension do
  alias Cubit.Dimension
  alias Cubit.Base

  defstruct [:dims]

  @type t :: %Dimension{
          dims: Base.t() | [{t, integer}]
        }

  @spec new(Base.base_name() | t | [{t, integer}]) :: t
  def new(name) when is_atom(name), do: %Dimension{dims: Base.new(name)}
  def new(%Dimension{dims: %Base{}} = d), do: d
  def new(%Dimension{dims: [_ | _] = dims}), do: new(dims)

  def new(dims) when is_list(dims) do
    base_dims =
      dims
      |> to_base(1)
      |> consolidate_dims()

    %Dimension{dims: base_dims}
  end

  @spec to_base(t | [{t, integer}], integer) :: [{t, integer}]
  defp to_base(dims, exp) when is_list(dims),
    do: Enum.flat_map(dims, fn {d, e} -> to_base(d, exp * e) end)

  defp to_base(%Dimension{dims: %Base{}} = d, exp), do: [{d, exp}]
  defp to_base(%Dimension{dims: dims}, exp), do: to_base(dims, exp)

  @spec consolidate_dims([{t, integer}]) :: [{t, integer}]
  defp consolidate_dims(dims) do
    dims
    |> Enum.reduce(%{}, fn {d, e}, acc -> Map.update(acc, d, e, &(&1 + e)) end)
    |> Map.to_list()
    |> Enum.reject(fn {_d, e} -> e == 0 end)
  end

  @spec pow(t, integer) :: t
  def pow(%Dimension{}, 0), do: new([])
  def pow(%Dimension{} = d, exp) when is_integer(exp), do: to_dims(d) |> apply_exp(exp) |> new()

  @spec apply_exp([{t, integer}], integer) :: [{t, integer}]
  defp apply_exp(dims, exp), do: Enum.map(dims, fn {d, e} -> {d, e * exp} end)

  @spec multiply(t, t) :: t
  def multiply(%Dimension{} = d1, %Dimension{} = d2),
    do: Enum.concat(to_dims(d1), to_dims(d2)) |> new()

  @spec divide(t, t) :: t
  def divide(%Dimension{} = d1, %Dimension{} = d2), do: d2 |> pow(-1) |> multiply(d1)

  @spec equal?(t, t) :: boolean
  def equal?(%Dimension{} = d1, %Dimension{} = d2), do: MapSet.equal?(to_set(d1), to_set(d2))

  @spec to_set(t) :: MapSet.t({t, integer()})
  defp to_set(%Dimension{} = d), do: d |> new() |> to_dims() |> MapSet.new()

  @spec to_dims(t) :: [{t, integer}]
  defp to_dims(%Dimension{dims: %Base{}} = d), do: [{d, 1}]
  defp to_dims(%Dimension{dims: dims}) when is_list(dims), do: dims
end
