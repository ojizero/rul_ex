defmodule Rulex.Guards do
  defguard is_val(expr)
           when is_tuple(expr) and
                  tuple_size(expr) == 2 and
                  elem(expr, 0) == :val and
                  expr |> elem(1) |> is_list() and
                  expr |> elem(1) |> length() == 2 and
                  expr |> elem(1) |> hd() |> is_binary()

  defguard is_var(expr)
           when is_tuple(expr) and
                  tuple_size(expr) == 2 and
                  elem(expr, 0) == :var and
                  expr |> elem(1) |> is_list() and
                  (expr |> elem(1) |> length()) in [2, 3] and
                  expr |> elem(1) |> hd() |> is_binary()

  defguard is_val_or_var(expr) when is_val(expr) or is_var(expr)

  defguard is_reserved_operand(op)
           when op in [:|, :&, :!, :=, :!=, :<, :>, :<=, :>=, :in, :val, :var, :var_or]

  defguard is_valid_operand(op) when is_reserved_operand(op) or is_binary(op)
end
