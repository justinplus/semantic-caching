require_relative 'constant'

require 'active_support/core_ext/benchmark'
require 'json'

module ServiceFlow
  class Action
    attr_accessor :actor, :succ, :prev
    attr_reader :log
  end

  class WebAction < Action
    attr_accessor :method, :params
    Metrics.each { |m| attr_accessor m }
    alias_method :invoke_t, :pure_invoke_t

    def initialize(actor_or_options, method = nil, input = nil, output = nil, metrics = nil)
      @actor, @method, @input, @output = case actor_or_options
      when Hash
        actor_or_options.values_at('actor', 'method', 'input', 'output')
      else
        [actor_or_options, method, input, output]
      end

      if String === @actor
        @actor = Object.const_get("::WebAPI::#{@actor}").new
      end

      @log = []

      # TODO: deal with metrics
      # if options
        # Metrics.each { |m| self.send "#{m}=", options[m.to_s] }
      # end
    end

    def start(msg_or_params, which = 0)
      res = nil
      now = Time.now.to_s
      lapse = Benchmark.ms do
        params = which == 0 ? _bind(msg_or_params, @input) : msg_or_params
        @actor.send @method, params
        puts @actor.uri
        resp = JSON.parse(@actor.get)
        # unless resp['status'] == 0
          # raise <<-ERROR_MSG
          # Error_code: #{resp['status']}
          # URL: #{@actor.uri}
          # Response: #{resp}
          # ERROR_MSG
        # end
        # puts resp['results'][0];
        puts resp
        res = _bind(resp, @output)
      end
      @log << [ now, lapse ]
      res
    end

    def metrics 
      Hash[ Metrics.map { |m| [m, self.send(m)] } ]
    end

    def _bind(data, mapping)
      mapping.each_with_object({}) do |(key, val), hsh|
        hsh[key] = Array === val ? val.inject(data) { |m, k| m[k] } : val
      end
    end

  end
end

