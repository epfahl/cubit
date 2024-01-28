defmodule Cubit.Dimension.Base do
  @moduledoc """
  A `Base` struct represents a named base dimension.

  The purpose of this struct is to indicate an irreducible base dimension and to
  facilitate pattern matching.
  """
  defstruct [:name]

  @type name :: atom | binary
  @type t :: %__MODULE__{name: name}

  @doc """
  Create a new base struct with the given `name`.
  """
  @spec new(name) :: t
  def new(name) when is_atom(name) or is_binary(name), do: %__MODULE__{name: name}
end
