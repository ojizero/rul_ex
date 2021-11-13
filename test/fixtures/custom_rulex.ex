defmodule RulEx.Fixtures.CustomRulEx do
  use RulEx.Behaviour

  def operand("passthru", [expr], db) when is_val(expr) do
    with {:ok, value} <- value(expr, db), do: {:ok, is_truthy(value)}
  end

  def operand("error", _args, _db) do
    {:error, "i will always give an error"}
  end

  #
  # Test cases
  #
  def test_cases do
    [
      # Simple cases
      %{
        expr: ["passthru", [:val, "boolean", true]],
        db: %{},
        expected: {:ok, true},
        message: "we passthrough result from custom operand"
      },
      %{
        expr: ["passthru", [:val, "boolean", false]],
        db: %{},
        expected: {:ok, false},
        message: "we passthrough result from custom operand"
      },
      %{
        expr: ["passthru", [:val, "boolean", "non bool"]],
        db: %{},
        expected: {:error, "invalid value '\"non bool\"' given for type 'boolean'"},
        message: "we passthrough result from custom operand"
      },
      %{
        expr: ["error"],
        db: %{},
        expected: {:error, "i will always give an error"},
        message: "we passthrough result from custom operand"
      },

      # Nested cases
      %{
        expr: [:|, ["passthru", [:val, "boolean", false]], ["passthru", [:val, "boolean", true]]],
        db: %{},
        expected: {:ok, true},
        message: "custom operands are usable like normal operands"
      },
      %{
        expr: [:&, ["passthru", [:val, "boolean", false]], ["passthru", [:val, "boolean", true]]],
        db: %{},
        expected: {:ok, false},
        message: "custom operands are usable like normal operands"
      },
      %{
        expr: [
          :|,
          ["passthru", [:val, "boolean", "non bool"]],
          ["passthru", [:val, "boolean", true]]
        ],
        db: %{},
        expected: {:error, "invalid value '\"non bool\"' given for type 'boolean'"},
        message: "custom operands are usable like normal operands"
      },
      %{
        expr: [
          :|,
          ["passthru", [:val, "boolean", true]],
          ["passthru", [:val, "boolean", "non bool"]]
        ],
        db: %{},
        expected: {:ok, true},
        message:
          "note rul_ex is lazy in evaluation so if in a nested expression an error may not be evaluated"
      },
      %{
        expr: [
          :&,
          ["passthru", [:val, "boolean", "non bool"]],
          ["passthru", [:val, "boolean", false]]
        ],
        db: %{},
        expected: {:error, "invalid value '\"non bool\"' given for type 'boolean'"},
        message: "custom operands are usable like normal operands"
      },
      %{
        expr: [
          :&,
          ["passthru", [:val, "boolean", false]],
          ["passthru", [:val, "boolean", "non bool"]]
        ],
        db: %{},
        expected: {:ok, false},
        message:
          "note rul_ex is lazy in evaluation so if in a nested expression an error may not be evaluated"
      },
      %{
        expr: [:|, ["error"], ["passthru", [:val, "boolean", true]]],
        db: %{},
        expected: {:error, "i will always give an error"},
        message: "custom operands are usable like normal operands"
      },
      %{
        expr: [:&, ["passthru", [:val, "boolean", true]], ["error"]],
        db: %{},
        expected: {:error, "i will always give an error"},
        message: "custom operands are usable like normal operands"
      },

      # Default case when no catch all is implemetned
      %{
        expr: ["custom", [:val, "boolean", false]],
        db: %{},
        expected: {:error, "unsupported operand 'custom' provided"},
        message: "by default we reject any unknown operand"
      }
    ]
  end
end
