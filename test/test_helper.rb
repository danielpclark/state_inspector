$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'state_inspector'

require 'minitest/autorun'
require 'minitest/reporters'
require 'color_pound_spec_reporter'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Minitest::Reporters.use! [ColorPoundSpecReporter.new]

require 'state_inspector/helper'

class Minitest::Test
  include StateInspector::Helper
end
