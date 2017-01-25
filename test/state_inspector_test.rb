require 'test_helper'
require 'state_inspector/observers/internal_observer'
include StateInspector::Observers

class A; end

class Behavior
  def add a, b
    a + b
  end
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

  def test_method_inform_and_then_restore_original
    StateInspector::Reporter[Behavior] = InternalObserver.new

    b = Behavior.new
    assert_equal 9, b.add(4, 5)

    toggle_snoop_clean(b) do
      b.state_inspector.snoop_methods :add
      assert_equal 11, b.add(5, 6)
      assert_equal [[b, :add, 5, 6]], StateInspector::Reporter[Behavior].values
      b.state_inspector.restore_methods :add
      assert_equal 13, b.add(6, 7)
      assert_equal [[b, :add, 5, 6]], StateInspector::Reporter[Behavior].values
    end
    StateInspector::Reporter[Behavior].purge
  end

  def test_helper_removals
    b = Behavior.new
    refute b.informant?
    refute Behavior.instance_variable_defined? :@state_inspector
    toggle_snoop_clean(b) do
      assert b.informant?
      b.state_inspector.skip_setter_snoops
      assert Behavior.instance_variable_defined? :@state_inspector
    end
    refute b.informant?
    refute Behavior.instance_variable_defined? :@state_inspector
  end
end
