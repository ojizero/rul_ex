defprotocol RulEx.DataBag do
  @moduledoc """
  Protocol controlling providing facts to RulEx evaluation functions.

  ## Examples

      defimpl RulEx.DataBag, for: Keyword do
        def get(kw, key, default \\\\ nil) do
          Keyword.get(kw, key, default)
        end
      end
  """

  @doc """
  Given an term implementing the `RulEx.DataBag` behaviour, a key,
  and an optional default value, yield back the value found in
  the provided databag.

  ## Examples

      iex> 10 = RulEx.DataBag.get(%{"x" => 10}, "x")
      iex> 10 = RulEx.DataBag.get(%{"x" => 10}, "x", 11)
      iex> 11 = RulEx.DataBag.get(%{"y" => 10}, "x", 11)
  """
  @spec get(t, any) :: any
  @spec get(t, any, any) :: any
  def get(db, var, default \\ nil)
end

defimpl RulEx.DataBag, for: Map do
  @spec get(RulEx.Databag.t(), any) :: any
  @spec get(RulEx.Databag.t(), any, any) :: any
  defdelegate get(map, var), to: Map
  defdelegate get(map, var, default), to: Map
end
