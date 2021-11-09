defmodule Rulex.Operands do
  @moduledoc false

  @comparison_atoms [:=, :!=, :<, :>, :<=, :>=]
  @comparison_strings Enum.map(@comparison_atoms, &Atom.to_string/1)
  @comparison_operands @comparison_atoms ++ @comparison_strings

  @value_atom [:val]
  @value_string ["val"]
  @value_operands @value_atom ++ @value_string

  @variable_atom [:var]
  @variable_string ["var"]
  @variable_operands @variable_atom ++ @variable_string

  @nested_exprs_atoms [:|, :&, :!, :in]
  @nested_exprs_strings Enum.map(@nested_exprs_atoms, &Atom.to_string/1)
  @nested_exprs @nested_exprs_atoms ++ @nested_exprs_strings

  @reserved_atoms @nested_exprs_atoms ++ @comparison_atoms ++ @value_atom ++ @variable_atom
  @reserved_strings @nested_exprs_strings ++
                      @comparison_strings ++ @value_string ++ @variable_string
  @reserved @reserved_atoms ++ @reserved_strings

  @doc false
  def reserved, do: @reserved
  @doc false
  def reserved_atoms, do: @reserved_atoms
  @doc false
  def reserved_strings, do: @reserved_strings

  @doc false
  def comparison, do: @comparison_operands

  @doc false
  def comparison_atoms, do: @comparison_atoms

  @doc false
  def comparison_strings, do: @comparison_strings

  @doc false
  def value, do: @value_operands

  @doc false
  def value_atoms, do: @value_atom

  @doc false
  def value_strings, do: @value_string

  @doc false
  def variable, do: @variable_operands

  @doc false
  def variable_atoms, do: @variable_atom

  @doc false
  def variable_strings, do: @variable_string

  @doc false
  def nested, do: @nested_exprs

  @doc false
  def nested_atoms, do: @nested_exprs_atoms

  @doc false
  def nested_strings, do: @nested_exprs_strings

  @doc false
  def rename(op) when op in @reserved_strings, do: String.to_existing_atom(op)
  def rename(any), do: any
end
