defmodule RulexTest do
  use ExUnit.Case, async: true
  doctest Rulex

  import Rulex

  alias Rulex.Fixtures.{Eval, Value}

  describe "Rulex" do
    test "eval/2" do
      for %{expr: tc, db: db, expected: expected, message: message} <- Eval.test_cases() do
        assert expected == eval(tc, db), message
      end
    end

    test "eval!/2" do
      for %{expr: tc, db: db, expected: expected, message: message} <- Eval.test_cases() do
        case expected do
          {:ok, expected} -> assert expected == eval!(tc, db), message
          {:error, _reason} -> assert_raise Rulex.EvalError, fn -> eval!(tc, db) end
        end
      end
    end

    test "expr?/1" do
      for %{expr: tc} <- Eval.valid_expressions() do
        assert expr?(tc), "failed to detect valid expression #{inspect(tc)}"
      end

      for %{expr: tc} <- Eval.invalid_expressions() do
        refute expr?(tc), "failed to detect invalid expression #{inspect(tc)}"
      end
    end

    test "value/2" do
      for %{expr: tc, db: db, expected: expected, message: message} <- Value.test_cases() do
        assert expected == value(tc, db), message
      end
    end

    test "value!/2" do
      for %{expr: tc, db: db, expected: expected, message: message} <- Value.test_cases() do
        case expected do
          {:ok, expected} -> assert expected == value!(tc, db), message
          {:error, _reason} -> assert_raise Rulex.EvalError, fn -> value!(tc, db) end
        end
      end
    end
  end

  # # TODO: move this to a different test suite?
  # describe "extending Rulex" do
  #   test "does not pass reserved operands"

  #   test "passes custom operands values"

  #   test "yields custom operands errors"

  #   test "yields an error on undefined custom operands (default implementation)"
  # end
end
