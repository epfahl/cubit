defmodule Cubit.Base do
  @moduledoc """
  A `Base` struct represents a named base dimension.

  The only purpose of this struct is to clearly indicate base dimensions and to
  facilitate pattern matching.
  """
  defstruct [:name]

  @type base_name :: any
  @type t :: %__MODULE__{
          name: base_name
        }

  @doc """
  Create a new base struct.
  """
  @spec new(base_name) :: t
  def new(name) do
    %__MODULE__{name: name}
  end
end
