require 'yaml'

require 'path_constant'

module FlowCases
  FlowNames = %w(dining dining_lite exclusive parallel seq weather)
  RawFlows = FlowNames.each_with_object({}){ |f, ob| ob[f] = YAML.load_file ::PathConstant::DataRoot.join("flow_#{f}.yml") }
end
