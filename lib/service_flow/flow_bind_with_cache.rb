require 'web_api'
require 'service_flow/action'
require 'service_flow/control'
require 'service_flow/source'
require 'service_flow/parallel'
require 'service_flow/exclusive'
require 'service_flow/helper'
require 'service_flow/cache_edge'
require 'cache'

require 'active_support/core_ext/object'

module ServiceFlow
  class FlowBindWithCache < Flow

    def initialize(flow)
      @source = Object.const_get("::ServiceFlow::#{flow.first['type']}").new(*flow.first['init_args'])
      flow = flow.drop 1

      @actions.flow.map do |action|
        Action.build action
      end

      @log = []
    end

  end
end
