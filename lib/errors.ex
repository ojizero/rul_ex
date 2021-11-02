defmodule Rulex.EvalError do
  defexception [:message, :reason, :expr, :facts]
end

defmodule Rulex.EncodeError do
  defexception [:message, :given]
end

defmodule Rulex.DecodeError do
  defexception [:message, :raw, :decoded, :decoder]
end
