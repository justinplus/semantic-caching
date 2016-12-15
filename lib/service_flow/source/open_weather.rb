require 'service_flow/source/base'
require 'path_constant'

require 'csv'

module ServiceFlow
  class OpenWeatherSource < Source
    include PathConstant

    @@table = [(CSV.table DataRoot.join('area_id_f.csv')),
               (CSV.table DataRoot.join('area_id_v.csv'))]

    @@normal_dist = CSV.read DataRoot.join('normal_dist_0.1_0.1.csv')
    @@normal_origin = [@@table[0].size / 2, @@table[1].size/2]

    def initialize
      @cur_row = [ -1, -1 ]
    end

    def next_f(mode, option = {})
      _next(:f, mode, option)
    end

    def next_v(mode, option = {})
      _next(:v, mode, option)
    end

    def next_id_f(mode, option = {})
      { 'area' => {'id' => _next(:f, mode, option)[0]}}
    end

    def next_id_v(mode, option = {})
      { 'area' => {'id' => _next(:v, mode, option)[0] }}
    end

    def _next(method, mode, option = {})
      index = method == :f ? 0 : 1
      case mode
      when :sequence, :seq
        @@table[index][(@cur_row[index]+=1) % @@table[index].size]
      when :uniform, :uni
        @@table[index][rand(@@table[index].size)]
      when :local, :loc
        option[:step] ||= 50
        step = rand(1000) > 500 ? option[:step] : -option[:step]
        @@table[index][(@cur_row[index]+=step) % @@table[index].size]
      when :normal, :nm
        @normal_index ||= -1
        @normal_index += 1
        offset = @@normal_dist[@normal_index][0].to_f * @@table[index].size
        offset = offset.to_i / 2
        # puts offset
        @@table[index][(@@normal_origin[index] + offset) % @@table[index].size]
      end

    end
  end
end

