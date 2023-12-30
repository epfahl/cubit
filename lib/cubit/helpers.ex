defmodule Cubit.Helpers do
  @moduledoc """
  Helper functions.
  """

  import Decimal, only: [is_decimal: 1]
  import Ratio, only: [is_rational: 1]

  @spec decimal_pow(Decimal.t(), integer | Ratio.t()) :: Decimal.t()
  def decimal_pow(dec, exp) when is_decimal(dec) do
    exp =
      case exp do
        exp when is_integer(exp) -> exp
        exp when is_rational(exp) -> Ratio.to_float(exp)
      end

    Decimal.from_float(Decimal.to_float(dec) ** exp)
  end
end
