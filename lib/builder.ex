defmodule Rulex.Builder do
  defmacro __using__(_opts) do
    quote do
      @behaviour Rulex.Behaviour
      @before_compile Rulex.Builder

      # TODO: from opts encoding module to use
      @impl Rulex.Behaviour
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

      @impl Rulex.Behaviour
      def apply!(expr, databag) do
        case apply(expr, databag) do
          {:ok, evaluation} ->
            evaluation

          {:error, reason} ->
            raise Rulex.ApplyError,
              message: "failed to complete expression application",
              reason: reason,
              facts: databag,
              expr: expr
        end
      end

      @impl Rulex.Behaviour
      def expr?(_any), do: false

      @impl Rulex.Behaviour
      def operand(_op, _args, _databag)

      defoverridable operand: 3
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      # Catchall operand call to reject with an error any undefined operands
      def operand(op, _args, _databag), do: {:error, "unsupported operand '#{op}' provided"}
    end
  end
end
