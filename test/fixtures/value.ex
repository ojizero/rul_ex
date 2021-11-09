defmodule Rulex.Fixtures.Value do
  def test_cases do
    [
      %{
        expr: [:val, "number", 10],
        db: %{},
        expected: {:ok, 10},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:val, "string", ""],
        db: %{},
        expected: {:ok, ""},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:val, "any", nil],
        db: %{},
        expected: {:ok, nil},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:val, "boolean", false],
        db: %{},
        expected: {:ok, false},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:var, "number", "x"],
        db: %{"x" => 10},
        expected: {:ok, 10},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:var, "string", "x"],
        db: %{"x" => ""},
        expected: {:ok, ""},
        message: "yields stored value correctly if typing is correct"
      },
      %{
        expr: [:var, "any", "x"],
        db: %{"x" => nil},
        expected: {:error, "invalid value 'nil' given for type 'any'"},
        message: "`var` rejects if it is to yield `nil`"
      },
      %{
        expr: [:var, "boolean", "x"],
        db: %{"x" => false},
        expected: {:ok, false},
        message: "yields stored value correctly if typing is correct"
      },

      # We parse string values if they are valid date, time, or datetime values
      %{
        expr: [:val, "date", "2021-01-01"],
        db: %{},
        expected: {:ok, ~D[2021-01-01]},
        message: "parses the value for date type if it is a string before yielding"
      },
      %{
        expr: [:var, "date", "x"],
        db: %{"x" => "2021-01-01"},
        expected: {:ok, ~D[2021-01-01]},
        message: "parses the value for date type if it is a string before yielding"
      },

      # We must reject any non `val` or `var` expressions
      %{
        expr: [:>, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:error, "cannot get value for non `val` or `var` expression"},
        message: "rejects arbitrary expressions that aren't `val` or `var`"
      },
      %{
        expr: [:=, [:val, "number", 10], [:val, "number", 9]],
        db: %{},
        expected: {:error, "cannot get value for non `val` or `var` expression"},
        message: "rejects arbitrary expressions that aren't `val` or `var`"
      }
    ]
  end
end
