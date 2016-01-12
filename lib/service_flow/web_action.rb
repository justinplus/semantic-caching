require 'service_flow/action'
require 'service_flow/metrics'
require 'service_flow/helper'

require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/enumerable'
require 'json'

module ServiceFlow
  class WebAction < Action
    include Metrics
    include Helper

    attr_accessor :actor, :method, :params
    attr_reader :input, :output

    # alias_method :invoke_t, :pure_invoke_t

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
    end

    def start(msg_or_params, which = 0)
      res = nil
      elapse = Benchmark.ms do
        tries = 0
        begin
          tries += 1
          params = which == 0 ? _bind(msg_or_params, @input) : msg_or_params.dup # TODO
          @actor.send @method, params
          resp = JSON.parse(@actor.get)
          Log.debug <<-DEBUG
Call #{@actor.class}, method: #{@method}, params: #{params}
URL: #{@actor.uri}
Resp: #{resp}
          DEBUG
          unless resp['status'].nil? || resp['status'] == 0 
            raise resp['message'].nil? ? 'wrong status' : "#{resp['message']}"
          end
          if !resp['results'].nil? && resp['results'].empty?
            raise 'empty results'
          end
        rescue StandardError => e
          if(tries < 2)
            Log.warn "Retry-#{tries}: #{e}"
            sleep( 0.1 * 2 ** tries )
            retry
          else
            Log.fatal "Error: #{e}, type: #{e.class}, at: #{$@}"
            raise e
          end
        end

        res = _bind(resp, @output)
      end
      @log << elapse
      res
    end

    def log(scope = nil)
      case scope
      when :raw, nil
        @log
      else
        Helper.cnt_sum_avg(@log)
      end
    end

    BASIC_METRIC_NAMES.each do |m|
      define_method m do
        METRICS[actor.class.to_s.split('::').last][method][m]
      end
    end

    def valid_rate
      1 - refresh_freq.to_f / invoking_freq
    end

    def invalid_rate
      refresh_freq.to_f / invoking_freq
    end

  end
end

