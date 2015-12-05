require 'service_flow/source/base'
require 'path_constant'
require 'yaml'
require 'csv'

module ServiceFlow
  class BaiduSource < Source
    # longitude and latitude range of Shanghai, China
    @@long_range = Range.new 121.36, 121.58 
    @@lat_range = Range.new 31.14, 31.345

    @@tags = YAML.load_file "#{DataRoot}/tags_baidu.yml"
    @@tags_l1 = @@tags.keys
    @@tags_l2 = @@tags.each.each_with_object([]) { |(_, val), res| res << val.keys unless val.nil? }.flatten

    @@res_uid = CSV.read "#{DataRoot}/baidu_restaurant_uid.csv"
    @@uid = CSV.read "#{DataRoot}/baidu_uid.csv"

    def next_loc
      long = (rand * (@@long_range.last - @@long_range.first)) + @@long_range.first
      lat = (rand * (@@lat_range.last - @@lat_range.first)) + @@lat_range.first
      if block_given?
        yield long, lat
      else
        [long, lat]
      end
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
