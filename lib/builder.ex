defmodule Rulex.Builder do
  import Rulex.Guards

  defmacro __using__(_opts) do
    quote do
      import Rulex.Guards

      @behaviour Rulex.Behaviour
      @before_compile Rulex.Builder

      # TODO: from opts encoding module to use

      @impl Rulex.Behaviour
      def apply({:|, args}, databag)
          when is_list(args) do
        Enum.reduce_while(args, {:ok, true}, fn arg, acc ->
          if expr?(arg) do
            case apply(arg, databag) do
              {:error, reason} -> {:halt, {:error, reason}}
              {:ok, result} -> if(result, do: {:halt, {:ok, true}}, else: {:cont, {:ok, false}})
            end
          else
            {:error, "non expressions provided"}
          end
        end)
      end

      def apply({:|, args}, _databag),
        do: {:error, "non list arguments #{inspect(Args)} provided to `|` operand"}

      def apply({:&, args}, databag)
          when is_list(args) do
        Enum.reduce_while(args, {:ok, true}, fn arg, acc ->
          if expr?(arg) do
            case apply(arg, databag) do
              {:error, reason} -> {:halt, {:error, reason}}
              {:ok, result} -> if(result, do: {:cont, {:ok, true}}, else: {:halt, {:ok, false}})
            end
          else
            {:error, "non expressions provided"}
          end
        end)
      end

      def apply({:&, args}, _databag),
        do: {:error, "non list arguments #{inspect(Args)} provided to `&` operand"}

      def apply({op, [expr0, expr1]}, databag)
          when op in [:<, :<=, :>, :>=, :=, :!=] and
                 is_val_or_var(expr0) and
                 is_val_or_var(expr1) do
        with t0 = elem(expr0, 1),
             t1 = elem(expr1, 1),
             {:type_match, true} <- {:type_match, t0 == t1},
             {:ok, v0} <- Rulex.Builder.__apply_var_or_val__(expr0, databag),
             {:ok, v1} <- Rulex.Builder.__apply_var_or_val__(expr1, databag) do
          op =
            case op do
              :< -> &Kernel.</2
              :<= -> &Kernel.<=/2
              :> -> &Kernel.>/2
              :>= -> &Kernel.>=/2
              := -> &Kernel.==/2
              :!= -> &Kernel.!=/2
            end

          IO.inspect({:applying, op, :on, v0, v1, apply(op, [v0, v1])})

          {:ok, op.(v0, v1)}
        else
          {:type_match, false} -> {:error, "type mismatch in `<` operand"}
          reason -> reason
        end
      end

      def apply({op, args}, _databag)
          when op in [:<, :<=, :>, :>=, :=, :!=] do
        {
          :error,
          "operand `#{op}` given invalid values #{inspect(args)} can only accept two arguments to compare"
        }
      end

      def apply({:in, [needle, haystack]}, _databag)
          when is_list(haystack),
          do: {:ok, needle in haystack}

      def apply({:in, args}, _databag) do
        {
          :error,
          "operand `in` given invalid values #{inspect(args)} can only accept list of two elements with the second being a list"
        }
      end

      def apply({op, args}, databag), do: operand(op, args, databag)

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
      def expr?({op, args})
          when is_valid_operand(op) and is_list(args),
          do: Enum.all?(args, &expr?/1)

      def expr?(_invalid_expr), do: false

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

  # TODO: if type mismatch give error
  def __apply_var_or_val__({:val, _type, value}, _databag), do: {:ok, value}
  # TODO: if nil or type mismatch give error
  def __apply_var_or_val__({:var, _type, value}, databag),
    do: {:ok, Rulex.DataBag.get(databag, value)}

  def __apply_var_or_val__({:var_or, _type, value, default}, databag),
    do: {:ok, Rulex.DataBag.get(databag, value, default)}

  def __apply_var_or_val__(expr, _databag)
      when is_tuple(expr) and elem(expr, 0) in [:val, :var, :var_or],
      do: {:error, "invalid `#{elem(expr, 0)}` with value #{inspect(expr)} provided"}

  def __apply_var_or_val__(expr, _databag),
    do: {:error, "invalid `val`, `var`, or `var_or` expression (`#{inspect(expr)}`) provided"}
end
