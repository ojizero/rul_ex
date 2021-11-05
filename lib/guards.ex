defmodule Rulex.Guards do
  @moduledoc "Provide helper guards for use with Rulex."

  @reserved_operands Rulex.Operands.reserved()

  @doc "Yield true if given expression is a valid `val` expression, false otherwise."
  defguard is_val(expr)
           when is_list(expr) and
                  length(expr) == 3 and
                  hd(expr) in [:val, "val"] and
                  expr |> tl |> hd |> is_binary()

  @doc "Yield true if given expression is a valid `var` expression, false otherwise."
  defguard is_var(expr)
           when is_list(expr) and
                  length(expr) in [3, 4] and
                  hd(expr) in [:var, "var"] and
                  expr |> tl |> hd |> is_binary()

  @doc "Yield true if given expression is a valid `val` or `var` expression, false otherwise."
  defguard is_val_or_var(expr) when is_val(expr) or is_var(expr)

  @doc "Yield true if given operand is reserved by Rulex, false otherwise."
  defguard is_reserved_operand(op)
           when op in @reserved_operands

  @doc "Yield true if give operand is a reserved operand or a string standing for any custom operands, false otherwise."
  defguard is_valid_operand(op) when is_reserved_operand(op) or is_binary(op)

  @doc "Yield true if given Elixir values is truthy, i.e. not `nil` or `false`, false otherwise."
  defguard is_truthy(value) when value not in [false, nil]

  @doc "Yield true if given Elixir values is falsy, i.e. `nil` or `false`, false otherwise."
  defguard is_falsy(value) when not is_truthy(value)
end
