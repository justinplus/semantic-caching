require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'
require 'path_constant'
require 'cache'

require 'yaml'

class FlowCacheTest < Minitest::Test
  include FlowCases
  include TestHelper

  def test_dining_lite
    mode, strategy, size_in_mb, loop_t, sleep_t = ARGV
    mode ||= :unit; mode = mode.to_sym
    strategy ||= :bss; strategy = strategy.to_sym
    size_in_mb ||= 4; size_in_mb = size_in_mb.to_i
    loop_t ||= 10000; loop_t = loop_t.to_i
    sleep_t ||= 0.2; sleep_t = sleep_t.to_f

    comment = "mode: #{mode}, strategy: #{strategy}, size_in_mb: #{size_in_mb}, loop_t: #{loop_t}, sleep_t: #{sleep_t}"

    # puts ARGV.inspect
    # puts [mode, strategy, size_in_mb, loop_t, sleep_t].inspect
    # puts comment.inspect

    ::Cache::CachePool.capacity = 1024 * 1024 * size_in_mb
    ::Cache::CachePool.strategy = strategy

    flow = ServiceFlow::Flow.new RawFlows['dining_lite']
    flow.transform! mode

    times = 0
    begin
      loop_t.times do
        flow.start
        puts times+=1
        sleep sleep_t
      end
    rescue
      puts "error:#{$!} at:#{$@}"
    ensure
      write_log "#{mode}_cache_pool_log_#{size_in_mb}", ::Cache::CachePool.log.to_yaml, comment: comment
      write_log "#{mode}_exec_log_#{size_in_mb}", {stat: flow.log(:s), raw: flow.log}.to_yaml, comment: comment
      write_log "#{mode}_cache_log_#{size_in_mb}", {stat: flow.cache_log(:s), raw: flow.cache_log}.to_yaml, comment: comment
    end
  end
end
