defmodule Rulex.Encoding do
  @moduledoc """
  This behaviour defines how to translate Rulex expressions into any
  encoding formats your application may want/need, e.g. converting
  them into JSON values.

  This is useful when you want to store Rulex expressions into database
  and/or if you want to transfer the rules over the wire to other
  services/systems that may need it.

  ## Usage

  A custom Rulex encoding mechanism can be defined by simply using `Rulex.Encoding`

      defmodule MyApp.Rulex.Encoder do
        use Rulex.Encoding

        def __encoder__, do: CustomModule
      end
  """

  @doc """
  Given a Rulex expression, encode it into any parsable value. This function will
  yield an error if given an invalid value in place of the Rulex expression,
  or if it fails to encode the provided expression.

  ## Examples

      iex> # Assuming the use of a JSON encoder
      iex> expression = [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
      iex> encoded = "[\\"|\\",[\\">\\",[\\"val\\",\\"number\\",10],[\\"var\\",\\"number\\",\\"x\\"]],[\\"=\\",[\\"val\\",\\"any\\",10],[\\"var\\",\\"any\\",\\"x\\"]]]"
      iex> {:ok, ^encoded} = encode(expression)
      iex> {:error, _reason} = encode([])
  """
  @callback encode(Rulex.t()) :: {:ok, any} | {:error, term}

  @doc "Exactly identical to `Rulex.Encoding.encode/1` but raises `Rulex.EncodeError` in case of errors."
  @callback encode!(Rulex.t()) :: any | no_return

  @doc """
  Given an encoded Rulex expression, decode it back into a Rulex expression.
  This function will yield an error if decoded value is an invalid Rulex
  expression, or if it fails to decode the provided value.

  ## Examples

      iex> # Assuming the use of a JSON encoder
      iex> encoded = "[\\"|\\",[\\">\\",[\\"val\\",\\"number\\",10],[\\"var\\",\\"number\\",\\"x\\"]],[\\"=\\",[\\"val\\",\\"any\\",10],[\\"var\\",\\"any\\",\\"x\\"]]]"
      iex> expression = [:|,[:>, [:val, "number", 10], [:var, "number", "x"]],[:=, [:val, "any", 10], [:var, "any", "x"]]]
      iex> {:ok, ^expression} = decode(encoded)
      iex> {:error, _reason} = decode("[]")
  """
  @callback decode(any) :: {:ok, Rulex.t()} | {:error, term}

  @doc "Exactly identical to `Rulex.Encoding.decode/1` but raises `Rulex.DecodeError` in case of errors."
  @callback decode!(any) :: Rulex.t() | no_return

  defmacro __using__(opts) do
    encoder = Keyword.get(opts, :encoder, Rulex.Encoding.Json)

    quote do
      alias Rulex.{EncodeError, DecodeError}

      require Rulex.Guards

      @behaviour Rulex.Encoding

      @doc """
      Default implementation for `Rulex.Encoding.encode/1`.

      Further more, this will return an error if the provided expression
      is not a valid Rulex expression.
      """
      @impl Rulex.Encoding
      def encode(maybe_expr) do
        with true <- Rulex.Builder.expr?(maybe_expr) do
          __encoder__().encode(maybe_expr)
        else
          false -> {:error, "cannot encode invalid expression"}
        end
      end

      @doc """
      Default implementation for `Rulex.Encoding.encode!/1`.

      Further more, this will return an error if the provided expression
      is not a valid Rulex expression.
      """
      @impl Rulex.Encoding
      def encode!(maybe_expr) do
        case encode(maybe_expr) do
          {:ok, encoder} ->
            encoder

          {:error, reason} ->
            raise EncodeError, message: reason, given: maybe_expr
        end
      end

      @doc """
      Default implementation for `Rulex.Encoding.decode/1`.

      Further more, this will return an error if the provided expression
      is not a valid Rulex expression.
      """
      @impl Rulex.Encoding
      def decode(maybe_encoded_expr) do
        with {:ok, maybe_expr} <- __encoder__().decode(maybe_encoded_expr),
             true <- Rulex.Builder.expr?(maybe_expr) do
          {:ok, atomize_reserved_operands(maybe_expr)}
        else
          false -> {:error, "decoded an invalid expression"}
          reason -> reason
        end
      end

      @doc """
      Default implementation for `Rulex.Encoding.decode!/1`.

      Further more, this will return an error if the provided expression
      is not a valid Rulex expression.
      """
      @impl Rulex.Encoding
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
           when Rulex.Guards.is_val_or_var(expr) do
        op = Rulex.Operands.rename(op)

        [op | exprs]
      end

      defp atomize_reserved_operands([op | exprs]) do
        op = Rulex.Operands.rename(op)

        exprs = Enum.map(exprs, &atomize_reserved_operands/1)

        [op | exprs]
      end
    end
  end
end

defmodule Rulex.Encoding.Json do
  use Rulex.Encoding

  def __encoder__, do: Application.get_env(:rulex, __MODULE__, encoder: Jason)[:encoder]
end
