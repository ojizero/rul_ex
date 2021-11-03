defmodule Rulex.Guards do
  @reserved_operands Rulex.Operands.reserved()

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

  defguard is_truthy(value) when value not in [false, nil]

  defguard is_falsy(value) when not is_truthy(value)
end
