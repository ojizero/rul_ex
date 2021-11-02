use Mix.Config

config :rulex, Rulex.Encoding, default: Rulex.Encoding.Json
config :rulex, Rulex.Encoding.Json, encoder: Jason
