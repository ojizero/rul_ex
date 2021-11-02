defmodule Rulex.Operands do
  @moduledoc false

  @reserved_atoms [:|, :&, :!, :=, :!=, :<, :>, :<=, :>=, :in, :val, :var, :var_or]
  @reserved_strings Enum.map(@reserved_atoms, &Atom.to_string/1)
  @reserved @reserved_atoms ++ @reserved_strings

  @doc false
  def reserved, do: @reserved
  @doc false
  def reserved_atoms, do: @reserved_atoms
  @doc false
  def reserved_strings, do: @reserved_strings

  for reserved_atom <- @reserved_atoms do
    reserved_string = Atom.to_string(reserved_atom)

    @doc false
    def rename(unquote(reserved_string)), do: unquote(reserved_atom)
  end

  def rename(any), do: any
end
