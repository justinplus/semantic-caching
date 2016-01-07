require 'service_flow/metrics'
require 'service_flow/helper'

module ServiceFlow
  class Fork
    include Metrics
    
    attr_accessor :prev, :succ, :branches

    def initialize(branches, cache_mode = nil)
      @branches = []
      branches.each { |b| @branches << Flow.new(b, cache_mode) }

      @log = []

    end

    def input
      branches.each_with_object({}) do |br, hsh|
        br.actions.first.input.each_value do |val|
          case val
          when Hash
            hsh[val['map'].first] = nil 
          when Array
            hsh[val.first] = nil 
          end
        end

      end
    end

    def transform!( cache_mode )
      branches.each { |br| br.transform!(cache_mode) }
    end

    def start(msg)
      res = nil
      lapse = Benchmark.ms do
        res = _start(msg)
      end
      @log << lapse
      res
    end

    def log(scope = nil)
      log = @branches.map{ |b| b.log(scope) } 
      log.unshift (scope.nil? || scope == :raw) ?  @log : Helper.cnt_sum_avg(@log)
    end 
    
    def cache_log(scope)
      @branches.map{ |b| b.cache_log(scope) }
    end

    [ 'hit_rate', 'query_time', 'caching_time' ].each do |m|
      define_method m do
        branches.inject(0) { |sum, br| sum + br.public_send(m) } / branches.size
      end
    end

    def valid_rate
      branches.inject(1) { |prod, n| prod * n.valid_rate }
    end

    def invalid_rate
      1 - valid_rate
    end

    def caching_cost
      # TODO:
      branches.map{ |br| br.caching_cost }.max
    end

    def invoking_time
      branches.map{ |br| br.invoking_time }.max
    end

    def split_scheme
      branches.map{ |br| br.split_scheme }
    end

  end
end

