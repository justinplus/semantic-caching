require_relative '../test_helper'
require_relative 'flow_cases'

require 'web_api'
require 'service_flow'
require 'csv'

flow = ::ServiceFlow::Flow.new FlowCases::RawFlows['search_hotel']

csv = CSV.open('hotel_uids.csv', 'a')

1000.times do |i|
  puts i
  sleep 0.5
  res =  flow.start
  res['hotel'].each { |hsh| csv << [ hsh['uid'], hsh['name']] } unless res['hotel'].nil?
end

