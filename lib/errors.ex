defmodule Rulex.EvalError do
  @moduledoc """
  An error risen if the given Rulex expression fails to evaluate
  for any reason when using the bang variant functions of
  the `Rulex.Behaviour` callbacks.
  """

  defexception [:message, :reason, :expr, :facts]
end

defmodule Rulex.EncodeError do
  @moduledoc """
  An error risen if the given Rulex expression fails to be encoded
  for any reason when using the bang variant functions of
  the `Rulex.Encoding` callbacks.
  """

  defexception [:message, :given]
end

defmodule Rulex.DecodeError do
  @moduledoc """
  An error risen if the given encoded Rulex expression fails to be
  decoded for any reason when using the bang variant functions
  of the `Rulex.Encoding` callbacks.
  """

  defexception [:message, :raw, :decoder]
end
