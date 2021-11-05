defmodule Ruelx.GuardsTest do
  use ExUnit.Case, async: false

  import Rulex.Guards

  test "is_val/1" do
    cases = [
      # Truthy cases
      {[:val, "string", "hello"], true},
      # Notice that this does not apply validation on types
      {[:val, "string", 10], true},
      {["val", "string", "hello"], true},
      {["val", "string", 10], true},
      # Falsy cases
      {[:val], false},
      {[:val, "any"], false},
      {[:val, "any", "value", "extra"], false},
      {[:var], false},
      {[:var, "any", "value"], false},
      {[:var, "any", "value", "default"], false},
      {["var", "any", "value"], false},
      {["var", "any", "value", "default"], false},
      {[], false},
      {[:=, [:val, "any", "a"], [:val, "any", "a"]], false}
    ]

    for {tc, expected} <- cases do
      assert expected == is_val(tc), "failed on #{inspect(tc)}"
    end
  end

  test "is_var/1" do
    cases = [
      # Truthy cases
      {[:var, "any", "value"], true},
      {[:var, "any", "value", "default"], true},
      {["var", "any", "value"], true},
      {["var", "any", "value", "default"], true},
      # Falsy cases
      {[:var], false},
      {[:val, "string", "hello"], false},
      {[:val, "string", 10], false},
      {[:var, "any", "value", "default", "extra"], false},
      {[:val], false},
      {[:val, "any"], false},
      {[:val, "any", "value", "extra"], false},
      {[], false},
      {[:=, [:var, "any", "a"], [:var, "any", "a"]], false}
    ]

    for {tc, expected} <- cases do
      assert expected == is_var(tc), "failed on #{inspect(tc)}"
    end
  end

  test "is_val_or_var/1" do
    cases = [
      # Truthy cases
      {[:val, "string", "hello"], true},
      {[:val, "string", 10], true},
      {["val", "string", "hello"], true},
      {["val", "string", 10], true},
      {[:var, "any", "value"], true},
      {[:var, "any", "value", "default"], true},
      {["var", "any", "value"], true},
      {["var", "any", "value", "default"], true},
      # Falsy cases
      {[:val], false},
      {[:val, "any"], false},
      {[:val, "any", "value", "extra"], false},
      {[:var], false},
      {[:var, "any", "value", "default", "extra"], false},
      {[], false},
      {[:=, [:var, "any", "a"], [:var, "any", "a"]], false}
    ]

    for {tc, expected} <- cases do
      assert expected == is_val_or_var(tc), "failed on #{inspect(tc)}"
    end
  end

  test "is_reserved_operand/1" do
    for reserved_operand <- Rulex.Operands.reserved() do
      assert is_reserved_operand(reserved_operand),
             "failed on operand #{inspect(reserved_operand)}"
    end
  end

  test "is_valid_operand/1" do
    for reserved_operand <- Rulex.Operands.reserved() do
      assert is_valid_operand(reserved_operand),
             "failed on reserved operand #{inspect(reserved_operand)}"
    end

    cases = [
      # Truthy cases
      {"custom operand", true},
      {"can", true},
      {"be", true},
      {"any", true},
      {"arbitrary", true},
      {"string", true},
      # Falsy cases
      {10, false},
      {[], false},
      {%{}, false},
      {false, false},
      {nil, false}
    ]

    for {tc, expected} <- cases do
      assert expected == is_valid_operand(tc), "failed on custom operand #{inspect(tc)}"
    end
  end

  test "is_truthy/1" do
    assert not is_truthy(nil)
    assert not is_truthy(false)
    assert is_truthy(0)
    assert is_truthy(10)
    assert is_truthy("string")
    assert is_truthy([])
    assert is_truthy(%{})
  end

  test "is_falsy/1" do
    assert is_falsy(nil)
    assert is_falsy(false)
    assert not is_falsy(0)
    assert not is_falsy(10)
    assert not is_falsy("string")
    assert not is_falsy([])
    assert not is_falsy(%{})
  end
end
