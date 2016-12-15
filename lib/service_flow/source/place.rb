require 'service_flow/source/base'
require 'path_constant'

require 'csv'

module ServiceFlow
  class PlaceSource < Source
    include PathConstant

    @@table = CSV.table DataRoot.join('place.csv')
    @@normal_dist = CSV.read DataRoot.join('normal_dist_0.1_0.1.csv')
    @@normal_origin = @@table.size / 2

    def initialize
      @cur_row = -1
    end

    def next(mode, option = {})
      case mode
      when :sequence, :seq
        @@table[(@cur_row+=1) % @@table.size]
      when :uniform, :uni
        @@table[rand(@@table.size)]
      when :normal, :nm
        @normal_index ||= -1
        @normal_index += 1
        offset = @@normal_dist[@normal_index][0].to_f * @@table.size
        offset = offset.to_i / 2
        # puts offset
        @@table[ (@@normal_origin + offset) % @@table.size]
      end
    end

    def next_id(mode, option = {})
      { 'hotel' => {'uid' => self.next(mode, option)[0]}}
    end
  end
end

