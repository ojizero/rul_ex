defmodule Rulex do
  @moduledoc """

  """

  @typedoc """

  """
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
          # Any custom user defined operands, anything before this is reserved by Rulex
          | String.t()

  @typedoc """

  """
  @type arg :: String.t() | number | DateTime.t() | NaiveDateTime.t() | Date.t() | list(arg) | any

  @typedoc """

  """
  @type expr :: op | arg

  @typedoc """

  """
  @type t :: [expr]

  use Rulex.Behaviour
end

# [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
