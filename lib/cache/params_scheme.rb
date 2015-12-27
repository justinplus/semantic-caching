require 'yaml'
require 'path_constant'

module Cache
  include PathConstant 

  ParamsScheme = YAML.load_file DataRoot.join('params_scheme.yml')
end
