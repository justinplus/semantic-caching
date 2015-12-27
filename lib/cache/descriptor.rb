module Cache
  class Descriptor
    attr_reader :params
    attr_accessor :content, :ttl

    def initialize(params, content, ttl)
      @params, @content, @ttl = params, content, ttl
    end

    def valid?
    end

    def invalid?
      !valid?
    end

    def to_json
      {params: @params, content: @content, ttl: @ttl}.to_json
    end

    # def to_key(params_scheme)
      # params_scheme.map { |p| [p['name'], params[p['name']]] }.join(':')
    # end

  end
end
