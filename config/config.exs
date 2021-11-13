use Mix.Config

config :rul_ex, RulEx.Encoding, default: RulEx.Encoding.Json
config :rul_ex, RulEx.Encoding.Json, encoder: Jason
