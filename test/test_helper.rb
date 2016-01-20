require 'minitest/autorun'

require 'yaml'

require 'path_constant'

module TestHelper
  def write_yaml_with_timestamp(file_name, data, options = {})
    comment = options.fetch :comment, nil
    
    file = File.open ::PathConstant::LogRoot.join("#{file_name}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"), 'w'
    file.write("\# #{comment}") unless comment.nil?
    file.write data.to_yaml
  end
end

