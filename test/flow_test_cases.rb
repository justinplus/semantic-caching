require 'yaml'
require 'path_constant'

module FlowTestCases

  BaiduMetrics = YAML.load_file "#{SemanticCaching::DataRoot}/metrics_baidu.yml"
  OpenWeatherMetrics = YAML.load_file "#{SemanticCaching::DataRoot}/metrics_open_weather.yml"

  BaiduFlow = [
    {
      type: 'WebAction',
      actor: 'Baidu',
      method: 'search',
      args: {},
      metrics: BaiduMetrics['search']
    },

    {
      type: 'WebAction',
      actor: 'Baidu',
      method: 'detail',
      args: {},
      metrics: BaiduMetrics['detail']
    },

    {
      type: 'WebAction',
      actor: 'Baidu',
      method: 'event',
      args: {},
      metrics: BaiduMetrics['event']
    }
  ]

  WeatherFlow = [
    { 
      type: 'WebAction',
      actor: 'OpenWeather',
      method: 'forecast_f',
      args: {},
      metrics: OpenWeatherMetrics['forecast_f']
    },
    { 
      type: 'WebAction',
      actor: 'OpenWeather',
      method: 'index_f',
      args: {},
      metrics: OpenWeatherMetrics['index_f']
    }
  ]


end

