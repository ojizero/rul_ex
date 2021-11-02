defmodule Rulex do
  @type op ::
          :|
          | :&
          | :!
          | :=
          | :!=
          | :<
          | :>
          | :<=
          | :>=
          | :in
          # Data related operands
          | :val
          | :var
          | :var_or
          # Any custom user defined operands, anything before this is reserved by Rulex
          | String.t()
  @type arg :: String.t() | number | DateTime.t() | NaiveDateTime.t() | Date.t() | list(arg) | any
  @type expr :: op | arg
  @type t :: [expr]

  defmodule EvalError do
    defexception [:message, :reason, :expr, :facts]
  end

  use Rulex.Builder
end

# [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
