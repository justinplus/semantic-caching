require 'minitest/autorun'

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

