require 'pathname'

module SemanticCaching
  Root = Pathname.new(__FILE__).realdirpath.parent.parent
  DataRoot = Root.join 'data'
end


