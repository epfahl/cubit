defmodule Cubit.Helpers do
  @spec to_decimal(number | Decimal.t()) :: Decimal.t()
  def to_decimal(%Decimal{} = num), do: num
  def to_decimal(num) when is_number(num), do: num |> to_string() |> Decimal.new()

  @spec decimal_pow(Decimal.t(), integer) :: Decimal.t()
  def decimal_pow(%Decimal{}, 0), do: Decimal.new(1)

  def decimal_pow(%Decimal{} = d, exp) when is_integer(exp) and exp > 0 do
    Enum.reduce(1..exp, Decimal.new(1), fn _, acc ->
      Decimal.mult(acc, d)
    end)
  end

  def decimal_pow(%Decimal{} = d, exp) when is_integer(exp) and exp < 0 do
    Decimal.div(1, d) |> decimal_pow(-exp)
  end
end
