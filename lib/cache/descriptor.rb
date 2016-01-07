module Cache
  class Descriptor
    attr_reader :params
    attr_accessor :content, :lru_time

    def initialize(params, content, lru_time)
      @params, @content, @lru_time = params, content, lru_time
    end

    def valid?
    end

    def invalid?
      !valid?
    end

    def to_json
      {params: @params, content: @content, lru_time: @lru_time}.to_json
    end

    # def to_key(params_scheme)
      # params_scheme.map { |p| [p['name'], params[p['name']]] }.join(':')
    # end

  end
end
