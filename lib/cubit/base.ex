defmodule Cubit.Dimension.Base do
  @moduledoc """
  A `Base` struct represents a named base dimension.

  The purpose of this struct is to indicate an irreducible base dimension and to
  facilitate pattern matching.
  """
  defstruct [:name]

  @type t :: %__MODULE__{name: any}

  @doc """
  Create a new base struct with the given `name`.
  """
  @spec new(any) :: t
  def new(name), do: %__MODULE__{name: name}
end
