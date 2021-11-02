defmodule Rulex.Encoding do
  @callback encode(Rulex.t()) :: {:ok, any} | {:error, term}
  @callback encode!(Rulex.t()) :: any | no_return
  @callback decode(any) :: {:ok, Rulex.t()} | {:error, term}
  @callback decode!(any) :: Rulex.t() | no_return
end

defmodule Rulex.Encoding.Json do
  import Rulex.Builder, only: [expr?: 1]

  alias Rulex.{EncodeError, DecodeError}

  @behaviour Rulex.Encoding

  # TODO: configurable encoding module (Jason vs whatever)

  @impl Rulex.Encoding
  def encode(maybe_expr) do
    with true <- expr?(maybe_expr) do
      encoder().encode(maybe_expr)
    else
      false -> {:error, "cannot encode invalid expression"}
    end
  end

  @impl Rulex.Encoding
  def encode!(maybe_expr) do
    with true <- expr?(maybe_expr) do
      encoder().encode!(maybe_expr)
    else
      false -> raise EncodeError, message: "cannot encode invalid expression", given: maybe_expr
    end
  end

  @impl Rulex.Encoding
  def decode(maybe_encoded_expr) do
    with {:ok, maybe_expr} <- encoder().decode(maybe_encoded_expr),
         true <- expr?(maybe_expr) do
      {:ok, maybe_expr}
    else
      false -> {:error, "decoded an invalid expression"}
      reason -> reason
    end
  end

  @impl Rulex.Encoding
  def decode!(maybe_encoded_expr) do
    maybe_expr = encoder().decode!(maybe_encoded_expr)

    if not expr?(maybe_expr) do
      raise DecodeError,
        message: "decoded an invalid expression",
        raw: maybe_encoded_expr,
        decoded: maybe_expr,
        decoder: encoder()
    end

    maybe_expr
  end

  defp encoder, do: Application.get_env(:rulex, __MODULE__, encoder: Jason)[:encoder]
end
