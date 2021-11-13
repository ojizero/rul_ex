defmodule Rulex do
  @moduledoc """
  Rulex is a rules engine and simplified expressions language for evaluating
  a set of conditions against a set of facts, yielding true or false on
  whether the provided facts adhere to the set of conditions given.

  ## Rulex expressions

  The expressions used by Rulex are inspired by Lisp, and are simply nested lists
  with the first element being an operand, think of it as a function, and the
  remaining elements arguments to this operand. Evaluating these expressions
  is done against a set of facts provided as a `Rulex.DataBag`, and the
  outcome is a boolean on whether or not the conditions match on
  the given facts.

  ### Supported operands

  #### Logical operands

  These operands can only be used in `Rulex.Behaviour.eval/2` callback, and only yield `true`
  or `false` results. They can be passed "facts" from outside the expressions using
  `Rulex.DataBag` and the value operands supported by Rulex.

  - The any operand `:|`, `"|"`, which matches any list of Rulex expressions and yields true
    if one of them yields true, false otherwise.
  - The all operand `:&`, `"&"`, which matches any list of Rulex expressions and yields true
    if non of them yields false, true otherwise.
  - The negation operand `:!`, which matches a single Rulex expressions and yields the negation
    of whatever the input expression yields, e.g. true for false, and false for true.
  - The equality operand `:=`, `"="`, which matches a two Rulex value expressions and yields
    true if they are equal, this operation is non strict, i.e. `1.0 = 0` is true.
  - The inequality operand `:!=`, `"!="`, which matches a two Rulex value expressions and yields
    true if they are not equal, this operation is non strict, i.e. `1.0 != 0` is false.
  - The less than operand `:<`, `"<"`, which matches a two Rulex value expressions and yields
    true if the one on the left hand side is less than the one on the right hand side.
  - The greater than operand `:>`, `">"`, which matches a two Rulex value expressions and yields
    true if the one on the left hand side is greater than the one on the right hand side.
  - The less than or equals operand `:<=`, `"<="`, which matches a two Rulex value expressions and yields
    true if the one on the left hand side is less than or equals the one on the right hand side.
  - The greater than or equals operand `:>=`, `">="`, which matches a two Rulex value expressions and yields
    true if the one on the left hand side is greater than or equals the one on the right hand side.
  - The contains operand `:in`, `"in"`, which matches a "needle", a single Rulex value expressions, and a
    "haystack", a list of normal values (not Rulex expressions), and yields true if the needle exists
    in the given haystack.

  #### Value operands

  Value operands are used to represent data in a Rulex expressions, they are only two operands for this use case
  `:val` (`"val"`) and `:var` (`"var"`).

  `val` operand can be used in order to store exact values in the expressions, this includes the conditions
  you want to mean when applying the logical operands.

  `var` operand can be used in order to pass facts from outside of the expressions, this is done by using
  any Elixir term that implements the `Rulex.DataBag` protocol.

  Both these operands accept 2 arguments, a data type, and a value, the value in a `val` expressions is
  the actual value to be yielded back, while in a `var` expressions is they key used with `Rulex.DataBag`.
  The values are validated against the data type argument given, and would fail/be rejected if
  they don't match properly, i.e. you cannot return the value `"string"` when the data
  type expressed is `"numeric"`.

  The supported data types are,

  1. `"any"`, which will yield back any value without any validation.
  1. `"number"`, which will yield back any numeric value, regardless if an integer or float.
  1. `"integer"`, which will yield back only integer values.
  1. `"float"`, which will yield back only float values.
  1. `"string"`, which will yield back only strings.
  1. `"boolean"`, which will yield back only boolean values, i.e. `true` and `false`.
  1. `"list"`, which will yield back only lists of values, no validation is required on the values within the list.
  1. `"map"`, which will yield back only map of arbitrary keys and values, no validation is required on either the
     keys or the values within the map.
  1. `"time"`, which will yield back time values, it can be given string values and it will parse them, so long
     as those values are times as defined by ISO 8601.
  1. `"date"`, which will yield back date values, it can be given string values and it will parse them, so long
     as those values are dates as defined by ISO 8601.
  1. `"datetime"`, which will yield back date time values (naive datetime in Elixir terminology), it can be
     given string values and it will parse them, so long as those values are datetimes as defined by ISO 8601.

  Currently Rulex does not support any other additional types, and all of it's operations regarding values are
  strictly typed, meaning it will reject to complete operations if types don't match.

  #### Reserved operands

  Rulex reserves all the previously defined expressions as defined in *Logical operands* and in
  *Value operands*, in both their string and atom formats. Rulex also disallows for any
  non-reserved operand that isn't a string. Rulex does however allow for adding
  *custom operands* as defined in Custom operand.

  #### Custom operands

  Rulex behaviour can be extended with any arbitrary custom operands by simply defining the `Rulex.Behaviour.opernad/3`
  callback, this will receive the operand string, a list of arguments given to the operand, and the current data bag
  holding the facts being processed.

  ### Example expressions

  You can view the test suite for example expressions of a variety of types and forms, in short an expression is
  simply a list of arbitrarily nested Rulex valid values, this includes other Rulex expressions and normal
  Elixir terms, e.g. `[:=, [:val, "any", "hello"], [:val, "any, "world"]]` is a valid expression.

  Think of Rulex expressions very similarly to how [Lisp](https://en.wikipedia.org/wiki/Lisp_(programming_language))
  syntax works, these can be built and manipulated by code easily due to their easy to use structure. Some
  examples are given below, for more varied examples please check the test suite!

      [ :!
      , [ :=
        , [ :val
          , "string"
          , "some value"
          ]
        , [ :val
          , "string"
          , "some other value"
          ]
        ]
      ]

      [ :|
      , [ :=
        , [ :val
          , "string"
          , "some value"
          ]
        , [ :val
          , "string"
          , "some other value"
          ]
        ]
      , [ :=
        , [ :val
          , "numeric"
          , 10
          ]
        , [ :val
          , "numeric"
          , 10.0
          ]
        ]
      ]

  ### Storing and transporting these expressions

  Rulex provides the `Rulex.EncodeError` behaviour used to define converting Rulex expressions
  from and to Elixir terms, this can be helpful when you need to store these expressions
  and/or to transfer these expressions over the wire. By default, a JSON encoding is
  implemented for you.

  ## Usage

  Simply use `Rulex` as is, as it implements the `Rulex.Behaviour` fully. However, if you wan to
  add custom operands to the set of supported rules, simply define the `Rulex.Behaviour` as is,
  and then run wild. To do so simply use `Rulex.Behaviour` in your module, then implement
  your custom operands by overriding the `Rulex.Behaviour.operand/3` callback.

  ## Caveats and quirks

  - If no arguments are given to the any (`:|`) operand, it will yield back `false`, [follow this issue in Elixir
    for a discussion around this behaviour](https://github.com/elixir-lang/elixir/issues/1508).
  - If no arguments are given to the all (`:&`) operand, it will yield back `true`.
  - Value expressions can be used in the `Rulex.Behaviour.eval/2` callback, the results will simply
    be converted based on their truthiness as defined by Elixir and Erlang (i.e. only `false`
    and `nil` are falsy values).
  - Logical expressions will always yield an error if passed to the `Rulex.Behaviour.value/2` callbacks.
  - Results coming back from custom `Rulex.Behaviour.operand/3` are treated like value expressions
    and are converted to booleans based on their truthiness.
  - If given a reserved expression but as a string instead of an atom, Rulex will convert it to an atom
    and use it as if it was passed as the atom for the reserved expression.
  - The comparison operands, `<`, `>`, `<=`, `>=`, `=`, and `!=` all validate that **both** arguments are
    `val` or `var` expressions of the same type before doing anything, and will yield an error otherwise.
  """

  @typedoc """
  The set of all supported operands by Rulex, these include a set of reserved
  operands, as well as any arbitrary strings that can be used to extend Rulex
  behaviour to match any custom domain that needs rules evaluation.
  """
  @type op ::
          :|
          | :&
          | :!
          | :=
          | :!=
          | :<
          | :>
          | :<=
          | :>=
          | :in
          # Data related operands
          | :val
          | :var
          # Any custom user defined operands, everything define before this
          # as well as their equivalent in string are al reserved by Rulex.
          | String.t()

  @typedoc "The set of all valid values that represent an \"argument\" in a Rulex expression."
  @type arg :: String.t() | number | DateTime.t() | NaiveDateTime.t() | Date.t() | list(arg) | any

  @typedoc """
  A Rulex expression is a list of operands and arguments, ideally these expressions *must* start with
  one operand and then be followed by any arbitrarily long set of arguments, the arguments can also
  be other Rulex expressions.

  In order to validate whether a given Rulex expression is valid or not you can use the callback
  `Rulex.Behaviour.expr?/1`. Operands and expressions can further be validated with the guards
  defined in the `Rulex.Guards` module.
  """
  @type t :: [op | arg | t]

  use Rulex.Behaviour
end
