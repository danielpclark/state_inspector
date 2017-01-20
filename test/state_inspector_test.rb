require 'test_helper'

class A
  attr_writer :thing, :apple, :orange
  attr_accessor :thing2, :apple2, :orange2
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

  def test_attrs_make_more_than_one
    assert_includes A.instance_methods, :apple=
    assert_includes A.instance_methods, :apple2
    assert_includes A.instance_methods, :apple2=
    assert_includes A.instance_methods, :orange=
    assert_includes A.instance_methods, :orange2
    assert_includes A.instance_methods, :orange2=
  end
end
