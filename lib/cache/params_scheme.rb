require 'yaml'
require 'path_constant'

module Cache
  ParamsScheme = YAML.load_file PathConstant::DataRoot.join('params_scheme.yml')
end
