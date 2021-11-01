defmodule Rulex.Encoding do
  @callback encode(Rulex.t()) :: {:ok, any} | {:error, term}
  @callback encode!(Rulex.t()) :: any | no_return
  @callback decode(any) :: {:ok, Rulex.t()} | {:error, term}
  @callback decode!(any) :: Rulex.t() | no_return
end

defmodule Rulex.Encoding.Json do
  @behaviour Rulex.Encoding

  # TODO: configurable encoding module (Jason vs whatever)

  @impl Rulex.Encoding
  def encode(_arg), do: {:error, "not implemented"}
  @impl Rulex.Encoding

  def encode!(_arg), do: raise("not implemented")
  @impl Rulex.Encoding

  def decode(_arg), do: {:error, "not implemented"}
  @impl Rulex.Encoding
  def decode!(_arg), do: raise("not implemented")
end
