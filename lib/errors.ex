defmodule RulEx.EvalError do
  @moduledoc """
  An error risen if the given RulEx expression fails to evaluate
  for any reason when using the bang variant functions of
  the `RulEx.Behaviour` callbacks.
  """

  defexception [:message, :reason, :expr, :facts]
end

defmodule RulEx.EncodeError do
  @moduledoc """
  An error risen if the given RulEx expression fails to be encoded
  for any reason when using the bang variant functions of
  the `RulEx.Encoding` callbacks.
  """

  defexception [:message, :given]
end

defmodule RulEx.DecodeError do
  @moduledoc """
  An error risen if the given encoded RulEx expression fails to be
  decoded for any reason when using the bang variant functions
  of the `RulEx.Encoding` callbacks.
  """

  defexception [:message, :raw, :decoder]
end
