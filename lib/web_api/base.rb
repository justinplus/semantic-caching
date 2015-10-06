require 'net/http'

module WebAPI
  class Base
    attr_accessor :output_format, :uri

    def query
      @query
    end

    def query= (query)
      @uri.path = @path 
      @query ||= {}
      query = @query.merge query
      @uri.query = URI.encode_www_form query 
    end

    def get
      data = Net::HTTP.get(@uri)
      if block_given?
        yield data
      else
        data
      end
    end

  end
end
