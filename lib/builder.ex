defmodule Rulex.Builder do
  import Rulex.Guards

  defmacro __using__(_opts) do
    quote do
      import Rulex.Guards

      @behaviour Rulex.Behaviour
      @before_compile Rulex.Builder

      # TODO: from opts encoding module to use?

      @impl Rulex.Behaviour
      def apply({:|, exprs}, db) when is_list(exprs) do
        Enum.any?(exprs, Rulex.Builder.__expr_evaluator__(__MODULE__, db))
      catch
        reason -> {:error, reason}
      else
        result -> {:ok, result}
      end

      def apply({:|, args}, _db),
        do: {:error, "non list arguments #{inspect(args)} provided to `|` operand"}

      def apply({:&, exprs}, db) when is_list(exprs) do
        Enum.all?(exprs, Rulex.Builder.__expr_evaluator__(__MODULE__, db))
      catch
        reason -> {:error, reason}
      else
        result -> {:ok, result}
      end

      def apply({:&, args}, _db),
        do: {:error, "non list arguments #{inspect(Args)} provided to `&` operand"}

      def apply({op, [expr0, expr1]}, db)
          when op in [:<, :<=, :>, :>=, :=, :!=] and
                 is_val_or_var(expr0) and
                 is_val_or_var(expr1) do
        with t0 = expr0 |> elem(1) |> hd(),
             t1 = expr1 |> elem(1) |> hd(),
             true <- t0 == t1,
             {:ok, v0} <- Rulex.Builder.__evaluate_val_or_var__(expr0, db),
             {:ok, v1} <- Rulex.Builder.__evaluate_val_or_var__(expr1, db) do
          op =
            case op do
              :< -> &Kernel.</2
              :<= -> &Kernel.<=/2
              :> -> &Kernel.>/2
              :>= -> &Kernel.>=/2
              := -> &Kernel.==/2
              :!= -> &Kernel.!=/2
            end

          {:ok, op.(v0, v1)}
        else
          false -> {:error, "type mismatch in `<` operand"}
          reason -> reason
        end
      end

      def apply({op, args}, _db)
          when op in [:<, :<=, :>, :>=, :=, :!=] do
        {
          :error,
          "operand `#{op}` given invalid values `#{inspect(args)}` can only accept two arguments (given as a list of two elements) to compare"
        }
      end

      def apply({:in, [needle, haystack]}, db)
          when is_val_or_var(needle) and is_list(haystack) do
        with {:ok, needle} <- Rulex.Builder.__evaluate_val_or_var__(needle, db),
             do: {:ok, needle in haystack}
      end

      def apply({:in, args}, _db) do
        {
          :error,
          "operand `in` given invalid values `#{inspect(args)}` can only accept list of two elements with the first one being a `val` or `var` expression and the second being a list"
        }
      end

      def apply({:!, [expr]}, db) do
        with {:ok, result} <- __MODULE__.apply(expr, db),
             do: {:ok, not result}
      end

      def apply({:!, args}, _db) do
        {
          :error,
          "operand `!` given in valid values `#{inspect(args)}` can only accept a single expression (given as a list of one item) to negate"
        }
      end

      def apply({op, args}, db) when not is_reserved_operand(op),
        do: __MODULE__.operand(op, args, db)

      @impl Rulex.Behaviour
      def apply!(expr, db) do
        case __MODULE__.apply(expr, db) do
          {:ok, evaluation} ->
            evaluation

          {:error, reason} ->
            raise Rulex.ApplyError,
              message: "failed to complete expression application",
              reason: reason,
              facts: db,
              expr: expr
        end
      end

      @impl Rulex.Behaviour
      def expr?(expr) when is_val_or_var(expr), do: true

      def expr?({op, args})
          when is_valid_operand(op) and is_list(args),
          do: Enum.all?(args, &expr?/1)

      def expr?(_invalid_expr), do: false

      @impl Rulex.Behaviour
      def operand(_op, _args, _db)

      defoverridable operand: 3
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      # Catchall operand call to reject with an error any undefined operands
      def operand(op, _args, _db), do: {:error, "unsupported operand '#{op}' provided"}
    end
  end

  defmacro __expr_evaluator__(mod, db) do
    quote do
      fn expr ->
        with true <- unquote(mod).expr?(expr),
             {:ok, result} <- unquote(mod).apply(expr, unquote(db)) do
          result
        else
          false -> throw("non expressions provided")
          {:error, reason} -> throw(reason)
        end
      end
    end
  end

  def __evaluate_val_or_var__({:val, [type, value]}, _db) do
    if valid_value?(type, value),
      do: {:ok, value},
      else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
  end

  def __evaluate_val_or_var__({:var, [type, variable]}, db) do
    value = Rulex.DataBag.get(db, variable)

    if not is_nil(value) and valid_value?(type, value),
      do: {:ok, value},
      else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
  end

  def __evaluate_val_or_var__({:var, [type, variable, default]}, db) do
    value = Rulex.DataBag.get(db, variable, default)

    if not is_nil(value) and valid_value?(type, value),
      do: {:ok, value},
      else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
  end

  def __evaluate_val_or_var__({:val, args}, _db) do
    {
      :error,
      "invalid `val` arguments (`#{inspect(args)}`) provided can only accept two arguments (given as list of two elements) with the first one a supported type"
    }
  end

  def __evaluate_val_or_var__({:var, args}, _db) do
    {
      :error,
      "invalid `val` arguments (`#{inspect(args)}`) provided can only accept two or three arguments (given as list of two elements) with the first one a supported type"
    }
  end

  def __evaluate_val_or_var__(expr, _db),
    do: {:error, "invalid `val` or `var` expression (`#{inspect(expr)}`) provided"}

  defp valid_value?("any", _value), do: true
  defp valid_value?("number", value), do: is_number(value)
  defp valid_value?("integer", value), do: is_integer(value)
  defp valid_value?("float", value), do: is_float(value)
  defp valid_value?("string", value), do: is_binary(value)
  defp valid_value?("boolean", value), do: is_boolean(value)
  defp valid_value?("list", value), do: is_list(value)
  defp valid_value?("map", value), do: is_map(value)
  defp valid_value?("time", value), do: match?({:ok, _time}, Time.from_iso8601(value))
  defp valid_value?("date", value), do: match?({:ok, _date}, Date.from_iso8601(value))

  defp valid_value?("datetime", value),
    do: match?({:ok, _datetime}, NaiveDateTime.from_iso8601(value))

  defp valid_value?(_unknown, _value), do: false
end
