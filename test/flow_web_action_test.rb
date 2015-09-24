require 'net/http'
require 'json'
require 'semantic_caching/flow'
require 'web_api/baidu_api'


baidu = BaiduAPI.new

action = SemanticCaching::Flow::WebAction.new
action.actor = baidu
action.method = :locate
action.parameter = { address: '上海交通大学闵行校区电院3号楼' } 

puts action.start
