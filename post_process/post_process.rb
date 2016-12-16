require 'yaml'
require 'csv'

module PostProcess
  extend self
  def extract_cache_pool(infile, outfile)
    CSV.open(outfile, 'w') do |csv|
      YAML.load_file(infile).each do |r|
        csv << r
      end
    end
  end

  def extract_exec_sum(infile, outfile)
    File.open(outfile, 'w').write YAML.load_file(infile)[:raw].first.to_csv
  end
end

