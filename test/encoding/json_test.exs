defmodule RulEx.Encoding.JsonTest do
  use ExUnit.Case, async: true

  import RulEx.Encoding.Json

  @valid_fixtures [
    {
      [
        :|,
        [:>, [:val, "number", 10], [:var, "number", "x"]],
        [:=, [:val, "any", 10], [:var, "any", "x"]]
      ],
      ~S(["|",[">",["val","number",10],["var","number","x"]],["=",["val","any",10],["var","any","x"]]])
    },
    {
      [
        :&,
        [:>, [:val, "number", 10], [:var, "number", "x"]],
        [:=, [:val, "any", 10], [:var, "any", "x"]]
      ],
      ~S(["&",[">",["val","number",10],["var","number","x"]],["=",["val","any",10],["var","any","x"]]])
    },
    {
      [
        :&,
        [
          :|,
          [:>, [:val, "number", 10], [:var, "number", "x"]],
          [:=, [:val, "any", 10], [:var, "any", "x"]],
          [
            :&,
            [:>, [:val, "number", 10], [:var, "number", "x"]],
            [:=, [:val, "any", 10], [:var, "any", "x"]]
          ]
        ],
        [:<=, [:val, "any", 10], [:var, "any", "x"]]
      ],
      ~S(["&",["|",[">",["val","number",10],["var","number","x"]],["=",["val","any",10],["var","any","x"]],["&",[">",["val","number",10],["var","number","x"]],["=",["val","any",10],["var","any","x"]]]],["<=",["val","any",10],["var","any","x"]]])
    },
    {
      [
        "custom",
        [:>, [:val, "number", 10], [:var, "number", "x"]],
        [:=, [:val, "any", 10], [:var, "any", "x"]]
      ],
      ~S(["custom",[">",["val","number",10],["var","number","x"]],["=",["val","any",10],["var","any","x"]]])
    }
  ]

  @invalid_expressions [
    10,
    [],
    [:var],
    [:val],
    [:val, "any"],
    [:val, "any", "value", "extra"],
    [:var, "any", "value", "default", "extra"],
    [:>],
    [:>, 10],
    [:>, 10, 20, 30],
    [:=, 10, 20, 30],
    [:=, 10],
    [:!],
    [:!, 10],
    [:&, 10, 20]
  ]

  @invalid_encoded_expressions [
    "10",
    "[]",
    ~S(["var"]),
    ~S(["val"]),
    ~S(["val", "any"]),
    ~S(["val", "any", "value", "extra"]),
    ~S(["var", "any", "something", "default", "extra"]),
    ~S([">"]),
    ~S([">", 10]),
    ~S([">", 10, 20, 30]),
    ~S(["=", 10, 20, 30]),
    ~S(["=", 10]),
    ~S(["!"]),
    ~S(["!", 10]),
    ~S(["&", 10, 20])
  ]

  describe "RulEx.Encoding.Json.encode/1" do
    test "success cases" do
      for {tc, expected} <- @valid_fixtures do
        assert {:ok, ^expected} = encode(tc)
      end
    end

    test "error cases" do
      for tc <- @invalid_expressions do
        assert {:error, _reason} = encode(tc)
      end
    end
  end

  describe "RulEx.Encoding.Json.encode!/1" do
    test "success cases" do
      for {tc, expected} <- @valid_fixtures do
        assert ^expected = encode!(tc)
      end
    end

    test "error cases" do
      for tc <- @invalid_expressions do
        assert_raise RulEx.EncodeError, fn -> encode!(tc) end
      end
    end
  end

  describe "RulEx.Encoding.Json.decode/1" do
    test "success cases" do
      for {expected, tc} <- @valid_fixtures do
        assert {:ok, ^expected} = decode(tc)
      end
    end

    test "error cases" do
      for tc <- @invalid_encoded_expressions do
        assert {:error, _reason} = decode(tc)
      end
    end
  end

  describe "RulEx.Encoding.Json.decode!/1" do
    test "success cases" do
      for {expected, tc} <- @valid_fixtures do
        assert ^expected = decode!(tc)
      end
    end

    test "error cases" do
      for tc <- @invalid_encoded_expressions do
        assert_raise RulEx.DecodeError, fn -> decode!(tc) end
      end
    end
  end
end
