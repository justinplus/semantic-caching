require 'yaml'
require 'path_constant'

module SemanticCaching
  ParamsScheme = YAML.load_file DataRoot.join('params_scheme.yml')
end
