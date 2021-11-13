defmodule RulEx.Fixtures.Eval do
  def test_cases, do: valid_expressions() ++ invalid_expressions() ++ value_expressions()

  def valid_expressions do
    comparison_test_cases() ++
      comparison_operands_type_mismatch() ++
      [
        # By default we reject unknown operands
        %{
          expr: ["custom", [:var, "boolean", false]],
          db: %{},
          expected: {:error, "unsupported operand 'custom' provided"},
          message: "by default we reject any unknown operand"
        }
      ]
  end

  def value_expressions do
    # Eval on `val` and `var` is done based on the
    [
      # truthiness of the resolved value
      %{
        expr: [:val, "number", 10],
        db: %{},
        expected: {:ok, true},
        message: "value `10` is truthy and must yield true"
      },
      %{
        expr: [:val, "number", 0],
        db: %{},
        expected: {:ok, true},
        message: "value `0` is truthy and must yield true"
      },
      %{
        expr: [:val, "string", ""],
        db: %{},
        expected: {:ok, true},
        message: "value `` (empty string) is truthy and must yield true"
      },
      %{
        expr: [:val, "date", "2021-01-01"],
        db: %{},
        expected: {:ok, true},
        message: "value `2021-01-01` (typed as date) is truthy and must yield true"
      },
      %{
        expr: [:val, "any", nil],
        db: %{},
        expected: {:ok, false},
        message: "value `nil` is falsy and must yield false"
      },
      %{
        expr: [:val, "boolean", false],
        db: %{},
        expected: {:ok, false},
        message: "value `false` is falsy and must yield false"
      },
      %{
        expr: [:var, "number", "x"],
        db: %{"x" => 10},
        expected: {:ok, true},
        message: "value `10` is truthy and must yield true"
      },
      %{
        expr: [:var, "number", "x"],
        db: %{"x" => 0},
        expected: {:ok, true},
        message: "value `0` is truthy and must yield true"
      },
      %{
        expr: [:var, "string", "x"],
        db: %{"x" => ""},
        expected: {:ok, true},
        message: "value `` (empty string) is truthy and must yield true"
      },
      %{
        expr: [:var, "date", "x"],
        db: %{"x" => "2021-01-01"},
        expected: {:ok, true},
        message: "value `2021-01-01` (typed as date) is truthy and must yield true"
      },
      %{
        expr: [:var, "any", "x"],
        db: %{"x" => nil},
        expected: {:error, "invalid value 'nil' given for type 'any'"},
        message: "`var` does not allow for value `nil` to be yielded back"
      },
      %{
        expr: [:var, "boolean", "x"],
        db: %{"x" => false},
        expected: {:ok, false},
        message: "value `false` is falsy and must yield false"
      }
    ]
  end

  def invalid_expressions do
    [
      %{
        expr: 10,
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects non valid expression `10`"
      },
      %{
        expr: [],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:var],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incomplete `var` expression"
      },
      %{
        expr: [:val],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incomplete `val` expression"
      },
      %{
        expr: [:val, "any"],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incomplete `val` expression"
      },
      %{
        expr: [:val, "any", "value", "extra"],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incorrect `val` expression"
      },
      %{
        expr: [:var, "any", "value", "default", "extra"],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incorrect `var` expression"
      },
      %{
        expr: [:>],
        db: %{},
        expected: {:error, nil},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:>, 10],
        db: %{},
        expected: {:error, nil},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:>, 10, 20, 30],
        db: %{},
        expected: {:error, nil},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:=, 10, 20, 30],
        db: %{},
        expected: {:error, nil},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:=, 10],
        db: %{},
        expected: {:error, nil},
        message: "rejects empty list as an expression"
      },
      %{
        expr: [:!],
        db: %{},
        expected: {:error, nil},
        message: "rejects incomplete `!` expression"
      },
      %{
        expr: [:!, 10],
        db: %{},
        expected: {:error, "invalid expression given"},
        message: "rejects incorrect `!` expression"
      },
      %{
        expr: [:&, 10, 20],
        db: %{},
        expected: {:error, "non expressions provided"},
        message: "rejects incorrect `&` expression"
      },
      %{
        expr: [:|, 10, 20],
        db: %{},
        expected: {:error, "non expressions provided"},
        message: "rejects incorrect `|` expression"
      }
    ]
  end

  defp comparison_test_cases do
    [
      # When data type is number
      %{
        expr: [:>, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, true},
        message: "comparison greater than on numbers"
      },
      %{
        expr: [:>, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison greater than on numbers"
      },
      %{
        expr: [:>, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison greater than on numbers"
      },
      %{
        expr: [:>=, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, true},
        message: "comparison greater than or equals on numbers"
      },
      %{
        expr: [:>=, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison greater than or equals on numbers"
      },
      %{
        expr: [:>=, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison greater than or equals on numbers"
      },
      %{
        expr: [:<, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, false},
        message: "comparison less than on numbers"
      },
      %{
        expr: [:<, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison less than on numbers"
      },
      %{
        expr: [:<, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison less than on numbers"
      },
      %{
        expr: [:<=, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, false},
        message: "comparison less than or equals on numbers"
      },
      %{
        expr: [:<=, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison less than or equals on numbers"
      },
      %{
        expr: [:<=, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison less than or equals on numbers"
      },
      %{
        expr: [:=, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, false},
        message: "comparison equals on numbers"
      },
      %{
        expr: [:=, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison equals on numbers"
      },
      %{
        expr: [:=, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison equals on numbers"
      },
      %{
        expr: [:!=, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:ok, true},
        message: "comparison equals not equals on numbers"
      },
      %{
        expr: [:!=, [:val, "number", 9], [:val, "number", 10]],
        db: %{},
        expected: {:ok, true},
        message: "comparison equals not equals on numbers"
      },
      %{
        expr: [:!=, [:val, "number", 10], [:val, "number", 10]],
        db: %{},
        expected: {:ok, false},
        message: "comparison equals not equals on numbers"
      }

      # TODO: other datatype
      # TODO: edge cases like dates and times
    ]
  end

  defp comparison_operands_type_mismatch do
    Enum.flat_map(RulEx.Operands.comparison(), fn op ->
      [
        %{
          expr: [op, [:val, "string", 10], [:val, "number", 9]],
          db: %{},
          expected: {:error, "type mismatch in `#{op}` operand"},
          message:
            "on numbers comparison operands must reject input if arguments have mismatching types"
        }
      ]
    end)
  end
end
