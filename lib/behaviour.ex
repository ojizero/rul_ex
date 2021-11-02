defmodule Rulex.Behaviour do
  @callback eval(Rulex.t(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}
  @callback eval!(Rulex.t(), Rulex.DataBag.t()) :: boolean | no_return

  @callback expr?(any) :: boolean

  @callback value({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: {:ok, any} | {:error, term}
  @callback value!({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: any | no_return

  @callback operand(String.t(), Rulex.arg(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  # TODO: encoding and decoding modules here?
  # TODO: add extensibility to types
end
