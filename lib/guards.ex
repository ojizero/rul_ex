defmodule Rulex.Guards do
  @reserved_operands_atoms [:|, :&, :!, :=, :!=, :<, :>, :<=, :>=, :in, :val, :var, :var_or]
  @reserved_operands @reserved_operands_atoms ++
                       Enum.map(@reserved_operands_atoms, &Atom.to_string/1)

  defguard is_val(expr)
           when is_list(expr) and
                  length(expr) == 3 and
                  hd(expr) in [:val, "val"] and
                  expr |> tl |> hd |> is_binary()

  defguard is_var(expr)
           when is_list(expr) and
                  length(expr) in [3, 4] and
                  hd(expr) in [:var, "var"] and
                  expr |> tl |> hd |> is_binary()

  defguard is_val_or_var(expr) when is_val(expr) or is_var(expr)

  defguard is_reserved_operand(op)
           when op in @reserved_operands

  defguard is_valid_operand(op) when is_reserved_operand(op) or is_binary(op)
end
