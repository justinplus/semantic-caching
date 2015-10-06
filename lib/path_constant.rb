require 'pathname'

module SemanticCaching
  RootPath = Pathname.new(__FILE__).realdirpath.parent.parent
  DataPath = RootPath.join 'data'
end


