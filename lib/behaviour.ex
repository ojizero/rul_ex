defmodule Rulex.Behaviour do
  @callback apply(Rulex.t(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}
  @callback apply!(Rulex.t(), Rulex.DataBag.t()) :: boolean | no_return
  @callback expr?(any) :: boolean
  @callback operand(String.t(), Rulex.arg(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  # TODO: encoding and decoding modules here?
  # TODO: add extensibility to types
end
