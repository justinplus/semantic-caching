require 'minitest/autorun'
require 'minitest/reporters'

module Minitest
  module Reporters
    def self.choose_reporters(console_reporters, env)
      if env["TM_PID"]
        [RubyMateReporter.new]
      elsif env["RM_INFO"] || env["TEAMCITY_VERSION"]
        [RubyMineReporter.new]
      else
        Array(console_reporters)
      end
    end
  end
end

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module TestHelper
  def get_data
    @baidu_metrics = YAML.load_file '../data/metrics_baidu.yml'
    @flow = [
      {
        type: 'WebAction',
        actor: 'Baidu',
        method: 'search',
        args: {},
        metrics: @baidu_metrics['search']
      },

      {
        type: 'WebAction',
        actor: 'Baidu',
        method: 'search',
        args: {},
        metrics: @baidu_metrics['search']
      },
      {
        type: 'WebAction',
        actor: 'Baidu',
        method: 'event',
        args: {},
        metrics: @baidu_metrics['event']
      }
    ]
  end
end

