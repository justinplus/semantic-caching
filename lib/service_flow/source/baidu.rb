require 'service_flow/source/base'
require 'path_constant'

require 'active_support/core_ext/enumerable'

require 'yaml'
require 'csv'

module ServiceFlow
  class BaiduSource < Source
    include PathConstant
    # lngitude and latitude range of Shanghai, China
    # @@lng_range = Range.new 121.36, 121.58 
    # @@lat_range = Range.new 31.14, 31.345

    @@normal_dist = CSV.read DataRoot.join('normal_dist_0.1_0.1.csv')
    @@radius = CSV.read DataRoot.join('radius.csv')
    @@tags = YAML.load_file DataRoot.join('tags_baidu.yml')
    @@tags_l1 = @@tags.keys
    @@tags_l2 = @@tags.each.each_with_object([]) { |(_, val), res| res << val.keys unless val.nil? }.flatten

    @@res_uid = CSV.read "#{DataRoot}/baidu_restaurant_uid.csv"
    @@uid = CSV.read "#{DataRoot}/baidu_uid.csv"

    def initialize( lt_lng, lt_lat, rb_lng, rb_lat, precision = 5 )
      # when lat = 30, delta 1 lng = 96 km
      @lng_range = [lt_lng, rb_lng]
      @lat_range = [lt_lat, rb_lat]
      @precision = precision
      @lng_center = @lng_range.sum / @lng_range.size
      @lat_center = @lat_range.sum / @lat_range.size
      @lng_delta = (@lng_range.last - @lng_range.first).abs
      @lat_delta = (@lat_range.last - @lat_range.first).abs
    end

    def next_loc(mode = nil)
      case mode
      when :uni, nil
        lng = (rand * (@lng_range.last - @lng_range.first)) + @lng_range.first
        lng = lng.round(@precision)
        lat = (rand * (@lat_range.last - @lat_range.first)) + @lat_range.first
        lat = lat.round(@precision)
        if block_given?
          yield lng, lat
        else
          [lng, lat]
        end
      when :normal, :nm
        @normal_index ||= 0
        lng = @lng_center + @lng_delta * @@normal_dist[@normal_index][0].to_f
        lat = @lat_center + @lat_delta * @@normal_dist[@normal_index][1].to_f
        @normal_index += 1
        [lng.round(@precision), lat.round(@precision)]
      end

    end

    def next_radius
      @radius_index ||= -1
      @radius_index += 1
      @@radius[@radius_index].first.to_i * 1000
    end

    def gen_msg(mode = nil)
      lng, lat = next_loc(mode)
      
      { 
        'origin' => {
          'lat' => lat,
          'lng' => lng
        },
        'query' => { 
          'q' => '餐厅',
          'radius' => next_radius
        }
      }

    end

    def next_tag_l1
      @@tags_l1[rand(@@tags_l1.size)]
    end

    def next_tag_l2
      @@tags_l2[rand(@@tags_l2.size)]
    end

    def next_uid
      @@uid[rand(@@uid.size)][1]
    end

    def next_res_uid
      @@res_uid[rand(@@res_uid.size)][1]
    end

  end
end
