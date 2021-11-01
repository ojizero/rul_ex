defmodule Rulex do
  @type op ::
          :|
          | :&
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
          # TODO: those shouldn't be operands but inputs to the operands var and val
          # # Type related operands
          # | :string
          # | :number
          # | :list
          # # Those are strictly in ISO 8601 format
          # | :date
          # | :time
          # | :date_time
          # Any custom user defined operands, anything before this is reserved by Rulex
          | String.t()
  @type arg :: String.t() | number | DateTime.t() | NaiveDateTime.t() | Date.t() | list(arg) | any
  @type expr :: {op, arg | [arg | expr]}
  @type t :: expr

  defmodule ApplyError do
    defexception [:message, :reason, :expr, :facts]
  end

  use Rulex.Builder
end
