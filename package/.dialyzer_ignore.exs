[
  # Ignore warnings from dependencies that we can't control
  {"deps/phoenix_pubsub", :_},
  {"deps/jason", :_},
  {"deps/uuidv7", :_},
  {"deps/elixir_uuid", :_},
  
  # Ignore specific warnings that are known false positives
  
  # Generated code warnings - the color_funcs module uses metaprogramming
  # to generate color combination functions dynamically
  {~r"Module.eval_quoted.*color_funcs", :_},
  {~r"Code.eval_quoted.*color_funcs", :_},
  
  # Optional dependencies warnings - phoenix_pubsub is optional
  {~r"Phoenix.PubSub.*optional", :_}
]
