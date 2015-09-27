module SemanticCaching
  class Flow
    CacheScheme = [:flow, :unit, 'flow', 'unit']

    Metrics = [:hit_r, :pure_invoke_t, :query_t, :refresh_f]
  end
end

