require_relative 'test_helper'
require 'semantic_caching/flow'

class TestFork < Minitest::Test
  include TestHelper

  def setup
    get_data
  end

  def test_new
    fork = SemanticCaching::Flow::Fork.new [@flow, @flow] 
    assert_equal 20+30+20+30, fork.pure_invoke_t
    assert_in_delta 20+30+20+30, fork.invoke_t
  end

end

