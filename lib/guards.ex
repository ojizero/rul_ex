defmodule Rulex.Guards do
  defguard is_val(expr) when is_tuple(expr) and tuple_size(expr) == 3 and elem(expr, 0) == :val

  defguard is_var_strict(expr)
           when is_tuple(expr) and tuple_size(expr) == 3 and elem(expr, 0) == :var

  defguard is_var_with_default(expr)
           when is_tuple(expr) and tuple_size(expr) == 4 and elem(expr, 0) == :var_or

  defguard is_var(expr) when is_var_strict(expr) or is_var_with_default(expr)

  defguard is_val_or_var(expr) when is_val(expr) or is_var(expr)

  defguard is_reserved_operand(op)
           when op in [:|, :&, :!, :=, :!=, :<, :>, :<=, :>=, :in, :val, :var, :var_or]

  defguard is_valid_operand(op) when is_reserved_operand(op) or is_binary(op)
end
