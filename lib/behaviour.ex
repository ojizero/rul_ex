defmodule Rulex.Behaviour do
  @moduledoc """
  This is the main behaviour describing Rulex and all the available callbacks
  and functions needed to fully implement rules evaluation.

  ## Usage

  A custom Rulex module can be defined by simply using `Rulex.Behaviour`

      defmodule MyApp.Rules do
        use Rulex.Behaviour
      end

  When using the default set of rules defined by Rulex, this is not needed as
  a default implementing already exists in `Rulex`.

  ### Extending Rulex operands



  ### Defining a default encoding mechanism


  """

  @doc """
  Given a Rulex expression (defined by the type `Rulex.t`), and a databag holding
  any contextual variable info (facts, implementing the protocol `Rulex.DataBag`),
  evaluate the expression against the databag and yield the result.

  This function **will** return an error if the expression given to it is an expression
  for the operands `:val` or `:var`, as those expressions yield any arbitrary value
  instead of a boolean result defining whether the Rulex expression is truthy
  or falsy given the facts provided (via the databag).

  ## Examples

  """
  @callback eval(Rulex.t(), Rulex.DataBag.t()) :: {:ok, boolean} | {:error, term}

  @doc "Exactly identical to `Rulex.Behaviour.eval/2` but raises `Rulex.EvalError` in case of errors."
  @callback eval!(Rulex.t(), Rulex.DataBag.t()) :: boolean | no_return

  @doc """
  Validate that the given term is a valid Rulex expression as defined by `Rulex.t`.

  ## Examples

  """
  @callback expr?(any) :: boolean

  @doc """
  Given a Rulex value expression (defined by the type `Rulex.t` of operands `:val` or `:var`),
  and a databag holding any contextual variable info (facts, implementing the protocol
  `Rulex.DataBag`), evaluate the value expression against the databag
  and yield the result.

  This function **will** return an error if the given any expression **except** those of
  the operands `:val` or `:var`.

  ## Examples

  """
  @callback value({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: {:ok, any} | {:error, term}

  @doc "Exactly identical to `Rulex.Behaviour.value/2` but raises `Rulex.EvalError` in case of errors."
  @callback value!({:var | :val, [Rulex.arg()]}, Rulex.DataBag.t()) :: any | no_return

  @doc """
  This function can be used to extend Rulex' defined operands arbitrarily by behaviour implementors.

  This function will never execute for any of the Rulex reserved operands, as defined
  by the type `Rulex.op`.

  ## Examples

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
