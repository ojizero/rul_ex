defmodule Rulex.Behaviour do
  # TODO: should this be allowed to evaluate back to anything?
  @callback apply(Rulex.t(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}
  @callback apply!(Rulex.t(), Rulex.DataBag.t()) :: boolean | no_return
  @callback expr?(any) :: boolean
  @callback operand(String.t(), Rulex.arg(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  # TODO: encoding and decoding modules here?
  # TODO: add extensibility to types

  defguard is_val(expr) when is_tuple(expr) and tuple_size(expr) == 3 and elem(expr, 0) == :val

  defguard is_var_strict(expr)
           when is_tuple(expr) and tuple_size(expr) == 3 and elem(expr, 0) == :var

  defguard is_var_with_default(expr)
           when is_tuple(expr) and tuple_size(expr) == 4 and elem(expr, 0) == :var_or

  defguard is_var(expr) when is_var_strict(expr) or is_var_with_default(expr)

  defguard is_val_or_var(expr) when is_val(expr) or is_var(expr)
end
