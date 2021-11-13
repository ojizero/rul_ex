defmodule RulExTest do
  use ExUnit.Case, async: true
  doctest RulEx

  import RulEx

  alias RulEx.Fixtures.{Eval, Value}

  test "eval/2" do
    for %{expr: tc, db: db, expected: expected, message: message} <- Eval.test_cases() do
      case expected do
        {:error, nil} -> assert match?({:error, _reason}, eval(tc, db)), message
        expected -> assert expected == eval(tc, db), message
      end
    end
  end

  test "eval!/2" do
    for %{expr: tc, db: db, expected: expected, message: message} <- Eval.test_cases() do
      case expected do
        {:ok, expected} -> assert expected == eval!(tc, db), message
        {:error, _reason} -> assert_raise RulEx.EvalError, fn -> eval!(tc, db) end
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
        {:error, _reason} -> assert_raise RulEx.EvalError, fn -> value!(tc, db) end
      end
    end
  end
end
