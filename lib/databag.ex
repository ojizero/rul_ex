defprotocol Rulex.DataBag do
  def get(db, var, default \\ nil)
end

defimpl Rulex.DataBag, for: Map do
  defdelegate get(map, var), to: Map
  defdelegate get(map, var, default), to: Map
end
