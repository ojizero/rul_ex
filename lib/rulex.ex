defmodule Rulex do
  @type op ::
          :|
          | :&
          | :<
          | :>
          | :<=
          | :>=
          | :in
          # Data related operands
          | :var
          | :val
          # Type related operands
          | :string
          | :number
          | :list
          # Those are strictly in ISO 8601 format
          | :date
          | :time
          | :date_time
          # Any custom user defined operands, anything before this is reserved by Rulex
          | String.t()
  @type arg :: String.t() | number | DateTime.t() | NaiveDateTime.t() | Date.t() | list(arg) | any
  @type expr :: {op, arg | [arg | expr]}
  @type t :: expr

  # TODO: should this be allowed to evaluate back to anything?
  @callback apply(t, Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}
  @callback apply!(t, Rulex.DataBag.t()) :: boolean | no_return
  @callback expr?(any) :: boolean

  defmodule ApplyError do
    defexception [:message, :reason, :expr, :facts]
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Rulex
      @before_compile Rulex

      # TODO: from opts encoding module to use

      def apply({:|, [_arg | __args] = _args}, _databag), do: {:ok, false}
      def apply({:|, _args}, _databag), do: {:error, "argument error"}

      def apply({:&, [_arg | __args] = _args}, _databag), do: {:ok, false}
      def apply({:&, _args}, _databag), do: {:error, "argument error"}

      def apply({:<, [_arg0, _arg1]}, _databag), do: {:ok, false}
      def apply({:<, _args}, _databag), do: {:error, "argument error"}

      def apply({:>, [_arg0, _arg1]}, _databag), do: {:ok, false}
      def apply({:>, _args}, _databag), do: {:error, "argument error"}

      def apply({:<=, [_arg0, _arg1]}, _databag), do: {:ok, false}
      def apply({:<=, _args}, _databag), do: {:error, "argument error"}

      def apply({:>=, [_arg0, _arg1]}, _databag), do: {:ok, false}
      def apply({:>=, _args}, _databag), do: {:error, "argument error"}

      def apply({:in, [_arg0 | __args] = _args}, _databag), do: {:ok, false}
      def apply({:in, _args}, _databag), do: {:error, "argument error"}

      def apply({op, args}, databag) do
        # if args is expr? rerun apply else run operand (custom)
        operand(op, args, databag)
        # {:error, "not implemented"}
      end

      def expr?(_any), do: false

      def apply!(expr, databag) do
        case apply(expr, databag) do
          {:ok, evaluation} ->
            evaluation

          {:error, reason} ->
            raise Rulex.ApplyError,
              message: "failed to complete expression evaluation",
              reason: reason,
              expr: expr
        end
      end

      # TODO: move this to a before before compile phase in order to have default catch all operand?
      def operand(_op, _args, _databag)

      # TODO: encoding and decoding modules here?

      defoverridable operand: 3
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def operand(op, _args, _databag), do: {:error, "unsupported operand '#{op}' provided"}
    end
  end
end

defmodule Rulex.Default do
  use Rulex

  def operand("x", _args, _databag), do: {:ok, true}
end
