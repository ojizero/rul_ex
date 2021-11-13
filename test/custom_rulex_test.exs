defmodule CustomRulexTest do
  use ExUnit.Case, async: true

  import Rulex.Fixtures.CustomRulex

  test "eval/2" do
    for %{expr: tc, db: db, expected: expected, message: message} <- test_cases() do
      assert expected == eval(tc, db), message
    end
  end

  test "eval!/2" do
    for %{expr: tc, db: db, expected: expected, message: message} <- test_cases() do
      case expected do
        {:ok, expected} -> assert expected == eval!(tc, db), message
        {:error, _reason} -> assert_raise Rulex.EvalError, fn -> eval!(tc, db) end
      end
    end
  end
end
