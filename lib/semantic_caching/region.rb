require 'semantic_caching/params_scheme'

module SemanticCaching
  class Region
    attr_accessor :data, :keys, :priority, :timestamp

    def initialize(keys, data, options)
      @params_scheme = ParamsScheme[options[:params_scheme]]
      @keys, @data = keys, data
    end

    def valid?
    end

    def refresh
    end

    def contain?(keys)
      self.keys.all?{ |key, val| val.send(@params_scheme[key.to_s]['contains'], keys[key]) }
    end
    
    alias_method :contains?, :contain?

    def eql?(keys)
      self.keys.all?{ |key, val| val.send(@params_scheme[key.to_s]['equal'], keys[key]) }
    end

  end
end
