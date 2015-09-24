require_relative 'baidu_api'

class direction
  def initialize
    super
    @uri.path = 'direction/v1'
  end

  def query(query)
  end

end

