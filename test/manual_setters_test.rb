require 'test_helper'
require 'state_inspector/observers/internal_observer'

class M
  def thing= val
    @thing = val
    @side_effect = val.to_s + " asdf"
  end 
end

StateInspector::Reporter[M] = StateInspector::Observers::InternalObserver.new

class ManualSetterTest < Minitest::Test
  def observer; StateInspector::Reporter[M] end
  def test_adds_hook_to_setter_defined_manually
    m = M.new
    m.state_inspector.snoop_setters :thing=
    m.thing = 42
    assert_empty observer.values
    # add hook
    m.thing = :smile
    assert_equal [[m, "@thing", 42, :smile]], observer.values
  end
end
