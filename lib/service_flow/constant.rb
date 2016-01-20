require 'logger'

require 'path_constant'

module ServiceFlow
  # CacheScheme = [:flow, :unit, 'flow', 'unit']

  # Metrics = [:hit_r, :pure_invoke_t, :query_t, :refresh_f]
  LRUConfig = { 'default' => { 'type' => 'LRUInBytes' },
              'Baidu:search' => { 'type' => 'NaiveSemanticLRUInBytes' } 
  }

  Log = Logger.new PathConstant::LogRoot.join("log-#{Time.now.strftime('%Y%m%d_%H%M%S')}.log")
  # Log = Logger.new STDOUT
end

