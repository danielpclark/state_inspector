require 'test_helper'
require 'state_inspector/observers/internal_observer'

class M
  def thing= val
    @thing = val
    @side_effect = val.to_s + " asdf"
  end 

  def carp *args
    nil
  end
end

StateInspector::Reporter[M] = StateInspector::Observers::InternalObserver.new

class ManualSetterTest < Minitest::Test
  def observer; StateInspector::Reporter[M] end
  def test_adds_hook_to_setter_defined_manually
    m = M.new
    m.toggle_informant
    m.thing = 42
    assert_empty observer.values

    m.state_inspector.snoop_setters :thing=

    m.thing = :smile
    assert_equal [[m, "@thing", 42, :smile]], observer.values
    m.toggle_informant
    observer.purge

    assert_equal "smile asdf", m.instance_variable_get(:@side_effect)
  end

  def test_plane_ol_method_call
    m = M.new
    m.toggle_informant
    m.carp :a, 1, "asdf"
    assert_empty observer.values

    m.state_inspector.snoop_methods :carp

    m.carp :a, 1, "asdf"
    assert_equal [[m, :carp, :a, 1, "asdf"]], observer.values
    m.toggle_informant
    observer.purge
  end
end
