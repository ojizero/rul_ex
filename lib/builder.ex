defmodule Rulex.Builder do
  @moduledoc false

  import Rulex.Guards

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Rulex.Guards

      @behaviour Rulex.Behaviour
      @before_compile Rulex.Builder

      @doc """
      Default implementation for `Rulex.Behaviour.eval/2`.

      ## Examples

          iex> import #{__MODULE__}
          iex> # Success cases
          iex> truthy_expression = [:=, [:val, "string", "hello"], [:var, "string", "what?"]]
          iex> falsy_expression = [:=, [:val, "string", "hello"], [:val, "string", "world"]]
          iex> {:ok, true} = eval(truthy_expression, %{"what?" => "hello"})
          iex> {:ok, false} = eval(falsy_expression, %{"what?" => "hello"})
          iex> invalid_expression = []
          iex> {:error, _reason} = eval(invalid_expression, %{})
      """
      @impl Rulex.Behaviour
      def eval(expr, db)
          when is_val_or_var(expr) do
        with {:ok, value} <- value(expr, db),
             do: is_truthy(value)
      end

      def eval([:| | exprs], db) do
        Enum.any?(exprs, &expr_evaluator(&1, db))
      catch
        reason -> {:error, reason}
      else
        result -> {:ok, result}
      end

      def eval([:& | exprs], db) do
        Enum.all?(exprs, &expr_evaluator(&1, db))
      catch
        reason -> {:error, reason}
      else
        result -> {:ok, result}
      end

      def eval([op, expr0, expr1], db)
          when op in [:<, :<=, :>, :>=, :=, :!=] and
                 is_val_or_var(expr0) and
                 is_val_or_var(expr1) do
        with t0 = Enum.at(expr0, 1),
             t1 = Enum.at(expr1, 1),
             true <- t0 == t1,
             {:ok, v0} <- value(expr0, db),
             {:ok, v1} <- value(expr1, db) do
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

      def eval([op | args], _db)
          when op in [:<, :<=, :>, :>=, :=, :!=] do
        {
          :error,
          "operand `#{op}` given invalid values `#{inspect(args)}` can only accept two arguments to compare"
        }
      end

      def eval([:in, needle, haystack], db)
          when is_val_or_var(needle) and
                 is_list(haystack) do
        with {:ok, needle} <- value(needle, db),
             do: {:ok, needle in haystack}
      end

      def eval([:in | args], _db) do
        {
          :error,
          "operand `in` given invalid values `#{inspect(args)}` can only accept list of two elements with the first one being a `val` or `var` expression and the second being a list"
        }
      end

      def eval([:!, expr], db) do
        with {:ok, result} <- eval(expr, db),
             do: {:ok, not result}
      end

      def eval([:! | args], _db) do
        {
          :error,
          "operand `!` given in valid values `#{inspect(args)}` can only accept a single expression to negate"
        }
      end

      def eval([op | args], db)
          when is_reserved_operand(op) and
                 is_binary(op),
          do: eval([String.to_existing_atom(op) | args], db)

      def eval([op | args], db)
          when not is_reserved_operand(op),
          do: operand(op, args, db)

      def eval(_invalid_expr, _db), do: {:error, "invalid expression given"}

      @doc "Default implementation for `Rulex.Behaviour.eval!/2`."
      @impl Rulex.Behaviour
      def eval!(expr, db) do
        case eval(expr, db) do
          {:ok, evaluation} ->
            evaluation

          {:error, reason} ->
            raise Rulex.EvalError,
              message: "failed to evaluate expression `#{inspect(expr)}`",
              reason: reason,
              facts: db,
              expr: expr
        end
      end

      @doc """
      Default implementation for `Rulex.Behaviour.expr?/1`.

      ## Examples

          iex> import #{__MODULE__}
          iex> correct_expression = [:=, [:val, "string", "hello"], [:var, "string", "what?"]]
          iex> incorrect_expression = []
          iex> true = expr?(correct_expression)
          iex> false = expr?(incorrect_expression)
      """
      @impl Rulex.Behaviour
      def expr?(expr), do: Rulex.Builder.expr?(expr)

      @doc """
      Default implementation for `Rulex.Behaviour.value/2`.

      ## Examples

          iex> import #{__MODULE__}
          iex> # Success cases
          iex> val_expression = [:val, "string", "foo"]
          iex> var_expression = [:var, "number", "x"]
          iex> {:ok, "foo"} = value(val_expression, %{})
          iex> {:ok, 10} = value(var_expression, %{"x" => 10})
          iex> # Error cases
          iex> {:error, _reason} = value(var_expression, %{})
          iex> {:error, _reason} = value([], %{})
      """
      @impl Rulex.Behaviour
      def value([:val, type, value], _db) do
        if valid_value?(type, value),
          do: {:ok, value},
          else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
      end

      def value([:var, type, variable], db) do
        value = Rulex.DataBag.get(db, variable)

        if not is_nil(value) and valid_value?(type, value),
          do: {:ok, value},
          else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
      end

      def value([:var, type, variable, default], db) do
        value = Rulex.DataBag.get(db, variable, default)

        if not is_nil(value) and valid_value?(type, value),
          do: {:ok, value},
          else: {:error, "invalid value '#{inspect(value)}' given for type '#{type}'"}
      end

      def value([:val | args], _db) do
        {
          :error,
          "invalid `val` arguments (`#{inspect(args)}`) provided can only accept two arguments (given as list of two elements) with the first one a supported type"
        }
      end

      def value([:var | args], _db) do
        {
          :error,
          "invalid `val` arguments (`#{inspect(args)}`) provided can only accept two or three arguments (given as list of two elements) with the first one a supported type"
        }
      end

      def value(expr, _db) do
        if expr?(expr) and not is_val_or_var(expr) do
          {:error, "cannot get value for non `val` or `var` expression"}
        else
          {:error, "invalid `val` or `var` expression (`#{inspect(expr)}`) provided"}
        end
      end

      @doc "Default implementation for `Rulex.Behaviour.value!/2`."
      @impl Rulex.Behaviour
      def value!(expr, db) do
        case value(expr, db) do
          {:ok, result} ->
            result

          {:error, reason} ->
            raise Rulex.EvalError,
              message: "failed to evaluate value expression `#{inspect(expr)}`",
              reason: reason,
              facts: db,
              expr: expr
        end
      end

      @doc """
      Default implementation for `Rulex.Behaviour.operand/3`. If not overridden this will always
      yield an error. No catchall clause is needed as it is already implemented.

      ## Examples

          iex> import #{__MODULE__}
          iex> {:error, _reason} = operand("whatever", "any value", %{})
      """
      @impl Rulex.Behaviour
      def operand(op, args, db)

      defoverridable operand: 3

      #
      # Private defined APIs
      #

      defp expr_evaluator(expr, db) do
        with true <- expr?(expr),
             {:ok, result} <- eval(expr, db) do
          result
        else
          false -> throw("non expressions provided")
          {:error, reason} -> throw(reason)
        end
      end

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
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      # Catchall operand call to reject with an error any undefined operands
      # TODO: add dialyzer ignore clause if this never matches
      def operand(op, _args, _db), do: {:error, "unsupported operand '#{op}' provided"}
    end
  end

  # This is defined here as to be reused by other internal modules
  # of Rulex, this isn't intended to be used externall for that
  # use the `expr?/1` function provided by the implementor
  # of Rulex behaviour.
  @doc false
  def expr?(expr) when is_val_or_var(expr), do: true

  def expr?([op | args])
      when is_valid_operand(op) and is_list(args),
      do: Enum.all?(args, &expr?/1)

  def expr?(_invalid_expr), do: false
end
