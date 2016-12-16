require_relative 'post_process'
require 'pathname'

path = Pathname.new ARGV[0]

raise 'not exists' unless path.exist?
out = path.to_path + '.csv'

PostProcess.extract_cache_pool path, out

`octave-cli plot_cache_pool_curve.m #{out}`
