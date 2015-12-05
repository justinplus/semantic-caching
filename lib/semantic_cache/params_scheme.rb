require 'yaml'
require 'path_constant'

module SemanticCache
  ParamsScheme = YAML.load_file DataRoot.join('params_scheme.yml')
end
