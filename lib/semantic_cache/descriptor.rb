module SemanticCache
  class Descriptor
    attr_reader :params
    attr_accessor :content, :ttl

    def valid?
    end

    def invalid?
      !invalid?
    end

  end
end
