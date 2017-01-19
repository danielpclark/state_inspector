require 'test_helper'

class A
  attr_writer :thing
  attr_accessor :thing2
end

class StateInspectorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::StateInspector::VERSION
  end

  def test_state_inspector_included
    assert A.instance_methods.include? :state_inspector
    assert A.instance_methods.include? :tell_si
    assert A.instance_methods.include? :informant?
    assert A.instance_methods.include? :toggle_informant
  end
end
