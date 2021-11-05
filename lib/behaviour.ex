defmodule Rulex.Behaviour do
  @moduledoc """
  This is the main behaviour describing Rulex and all the available callbacks
  and functions needed to fully implement rules evaluation.

  Optionally, using `Rulex.Behaviour` to generate your custom Rulex module can
  also implement the `Rulex.Encoding` behaviour.

  ## Usage

  A custom Rulex module can be defined by simply using `Rulex.Behaviour`

      defmodule MyApp.Rules do
        use Rulex.Behaviour
      end

  When using the default set of rules defined by Rulex, this is not needed as
  a default implementing already exists in `Rulex`.

  ### Extending Rulex operands

  Rulex behaviour provides the ability to extend it's supported operands arbitrarily
  via the `operand/3` callback, by default this will yield an error for all non
  reserved operands as defined by the type `Rulex.op`.

      defmodule MyApp.CustomRules do
        use Rulex.Behaviour

        # Here we're matching against our custom operand name
        # afterwards we assert that the single expression
        # given to us will yield `nil`.
        #
        # A catchall operand for all non-implemented operands
        # exists and will yield back an error.
        #
        def operand("nil?", [arg], db) do
          with value <- value(arg, db),
               do: {:ok, is_nil(value)}
        end
      end

  ### Defining a default encoding mechanism

  Rulex behaviour optionally allows you to provide a custom encoding mechanism
  to translate Rulex expression into whatever encoding you want/need.

  This is achieve by either setting the application environment to define a config
  for under `Rulex.Behaviour` key with a keyword list with `:default` key set
  to the encoding module (implementing the behaviour `Rulex.Encoding`).

      # In your `config/config.exs`
      config :rulex, Rulex.Behaviour, default: MyApp.Rulex.Encoder

  Further more, when defining the module you can pass `encoder` option when using
  this behaviour as such.

      defmodule MyApp.CustomRules do
        use Rulex.Behaviour, encoder: MyApp.Rulex.Encoder
      end

  Do note that passing the `:encoder` option overrides any application configurations
  set in the environment.

  You can disable the encoder behaviour all together by passing the option
  `:without_encoder` when using this behaviour, as such.

      defmodule MyApp.CustomRules do
        use Rulex.Behaviour, :without_encoder
      end

  > If no explicit encoding mechanism is provided, an the option `:without_encoder`
  > isn't passed, then using this behaviour to build your custom Rulex module
  > will use `Rulex.Encoding.Json` as an encoder to implement the
  > `Rulex.Encoding` behaviour.
  """

  @doc """
  Given a Rulex expression (defined by the type `Rulex.t`), and a databag holding
  any contextual variable info (facts, implementing the protocol `Rulex.DataBag`),
  evaluate the expression against the databag and yield the result.

  This function **will** return an error if the expression given to it is an expression
  for the operands `:val` or `:var`, as those expressions yield any arbitrary value
  instead of a boolean result defining whether the Rulex expression is truthy
  or falsy given the facts provided (via the databag).
  """
  @callback eval(Rulex.t(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  @doc "Exactly identical to `Rulex.Behaviour.eval/2` but raises `Rulex.EvalError` in case of errors."
  @callback eval!(Rulex.t(), Rulex.DataBag.t()) :: boolean | no_return

  @doc "Validate that the given term is a valid Rulex expression as defined by `Rulex.t`."
  @callback expr?(any) :: boolean

  @doc """
  Given a Rulex value expression (defined by the type `Rulex.t` of operands `:val` or `:var`),
  and a databag holding any contextual variable info (facts, implementing the protocol
  `Rulex.DataBag`), evaluate the value expression against the databag
  and yield the result.

  This function **will** return an error if the given any expression **except** those of
  the operands `:val` or `:var`.

  If the resolved value does not match the type specified in the expression this function
  will yield back an error. If given a `:var` expression, this function *should*
  yield back an error if the databag doesn't hold a value for the requested
  variable.

  This function will yield an error if given any expression that isn't a Rulex `:var` or
  `:var` expression, regardless of its correctness as a Rulex expression.
  """
  @callback value({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: {:ok, any} | {:error, term}

  @doc "Exactly identical to `Rulex.Behaviour.value/2` but raises `Rulex.EvalError` in case of errors."
  @callback value!({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: any | no_return

  @doc """
  This function can be used to extend Rulex' defined operands arbitrarily by behaviour implementors.

  This function will never execute for any of the Rulex reserved operands, as defined
  by the type `Rulex.op`.
  """
  @callback operand(String.t(), Rulex.arg(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  @doc false
  defmacro __using__(opts) do
    quote do
      use Rulex.Builder, unquote(opts)

      if :without_encoder not in unquote(opts) do
        use Rulex.Encoding, unquote(opts)
      end
    end
  end
end
