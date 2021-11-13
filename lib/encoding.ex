defmodule RulEx.Encoding do
  @moduledoc """
  This behaviour defines how to translate RulEx expressions into any
  encoding formats your application may want/need, e.g. converting
  them into JSON values.

  This is useful when you want to store RulEx expressions into database
  and/or if you want to transfer the rules over the wire to other
  services/systems that may need it.

  ## Usage

  A custom RulEx encoding mechanism can be defined by simply using `RulEx.Encoding`,
  and passing a module defining your encode and decode functions

      defmodule MyApp.RulEx.Encoder do
        use RulEx.Encoding, encoder: CustomModule
      end

  Alternatively the internal encoder can be passed as an option when using `RulEx.Encoding`

      defmodule MyApp.RulEx.Encoder do
        use RulEx.Encoding

        def __encoder__, do: CustomModule
      end

  Using this module to build your encoder is useful as the generated encoder would do
  validation on the RulEx expressions being encoded or decoded by it.
  """

  @doc """
  Given a RulEx expression, encode it into any parsable value. This function will
  yield an error if given an invalid value in place of the RulEx expression,
  or if it fails to encode the provided expression.

  ## Examples

      iex> # Assuming the use of a JSON encoder
      iex> expression = [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
      iex> encoded = "[\\"|\\",[\\">\\",[\\"val\\",\\"number\\",10],[\\"var\\",\\"number\\",\\"x\\"]],[\\"=\\",[\\"val\\",\\"any\\",10],[\\"var\\",\\"any\\",\\"x\\"]]]"
      iex> {:ok, ^encoded} = encode(expression)
      iex> {:error, _reason} = encode([])
  """
  @callback encode(RulEx.t()) :: {:ok, any} | {:error, term}

  @doc "Exactly identical to `RulEx.Encoding.encode/1` but raises `RulEx.EncodeError` in case of errors."
  @callback encode!(RulEx.t()) :: any | no_return

  @doc """
  Given an encoded RulEx expression, decode it back into a RulEx expression.
  This function will yield an error if decoded value is an invalid RulEx
  expression, or if it fails to decode the provided value.

  ## Examples

      iex> # Assuming the use of a JSON encoder
      iex> encoded = "[\\"|\\",[\\">\\",[\\"val\\",\\"number\\",10],[\\"var\\",\\"number\\",\\"x\\"]],[\\"=\\",[\\"val\\",\\"any\\",10],[\\"var\\",\\"any\\",\\"x\\"]]]"
      iex> expression = [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
      iex> {:ok, ^expression} = decode(encoded)
      iex> {:error, _reason} = decode("[]")
  """
  @callback decode(any) :: {:ok, RulEx.t()} | {:error, term}

  @doc "Exactly identical to `RulEx.Encoding.decode/1` but raises `RulEx.DecodeError` in case of errors."
  @callback decode!(any) :: RulEx.t() | no_return

  defmacro __using__(opts) do
    encoder = Keyword.get(opts, :encoder, RulEx.Encoding.Json)

    quote do
      alias RulEx.{EncodeError, DecodeError}

      require RulEx.Guards

      @behaviour RulEx.Encoding

      @doc """
      Default implementation for `RulEx.Encoding.encode/1`.

      Further more, this will return an error if the provided expression
      is not a valid RulEx expression.
      """
      @impl RulEx.Encoding
      def encode(maybe_expr) do
        with true <- RulEx.Builder.expr?(maybe_expr) do
          __encoder__().encode(maybe_expr)
        else
          false -> {:error, "cannot encode invalid expression"}
        end
      end

      @doc """
      Default implementation for `RulEx.Encoding.encode!/1`.

      Further more, this will return an error if the provided expression
      is not a valid RulEx expression.
      """
      @impl RulEx.Encoding
      def encode!(maybe_expr) do
        case encode(maybe_expr) do
          {:ok, encoder} ->
            encoder

          {:error, reason} ->
            raise EncodeError, message: reason, given: maybe_expr
        end
      end

      @doc """
      Default implementation for `RulEx.Encoding.decode/1`.

      Further more, this will return an error if the provided expression
      is not a valid RulEx expression.
      """
      @impl RulEx.Encoding
      def decode(maybe_encoded_expr) do
        with {:ok, maybe_expr} <- __encoder__().decode(maybe_encoded_expr),
             true <- RulEx.Builder.expr?(maybe_expr) do
          {:ok, atomize_reserved_operands(maybe_expr)}
        else
          false -> {:error, "decoded an invalid expression"}
          reason -> reason
        end
      end

      @doc """
      Default implementation for `RulEx.Encoding.decode!/1`.

      Further more, this will return an error if the provided expression
      is not a valid RulEx expression.
      """
      @impl RulEx.Encoding
      def decode!(maybe_encoded_expr) do
        case decode(maybe_encoded_expr) do
          {:ok, encoder} ->
            encoder

          {:error, reason} ->
            raise DecodeError, message: reason, raw: maybe_encoded_expr, decoder: __encoder__()
        end
      end

      @spec __encoder__ :: module
      def __encoder__, do: unquote(encoder)

      defoverridable __encoder__: 0

      #
      # Private APIs
      #

      defp atomize_reserved_operands([op | exprs] = expr)
           when RulEx.Guards.is_val_or_var(expr) do
        op = RulEx.Operands.rename(op)

        [op | exprs]
      end

      defp atomize_reserved_operands([op | exprs]) do
        op = RulEx.Operands.rename(op)

        exprs = Enum.map(exprs, &atomize_reserved_operands/1)

        [op | exprs]
      end
    end
  end
end

defmodule RulEx.Encoding.Json do
  use RulEx.Encoding

  def __encoder__, do: Application.get_env(:rul_ex, __MODULE__, encoder: Jason)[:encoder]
end
