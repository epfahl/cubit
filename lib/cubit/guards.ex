defmodule Cubit.Guards do
  @moduledoc """
  Guards for internal use.
  """

  import Decimal, only: [is_decimal: 1]

  defguard is_numeric(x) when is_number(x) or is_decimal(x)

  defguard pos_numeric(x)
           when (is_number(x) and x > 0) or
                  (is_decimal(x) and x.coef > 0 and x.sign == 1)
end
