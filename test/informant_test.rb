require 'test_helper'

class ScopedAllInstances; end
class Toggle; end

class InformantTest < Minitest::Test
  def test_informant_can_be_scoped_to_single_instance
    o = Object.new
    refute o.informant?
    o.toggle_informant
    assert o.informant?
    o = Object.new
    refute o.informant?
  end

  def test_informant_can_be_scoped_to_all_instances
    o = ScopedAllInstances.new
    refute o.informant?
    ScopedAllInstances.toggle_informant
    assert o.informant?
    o = ScopedAllInstances.new
    assert o.informant?
    o = Object.new
    refute o.informant?
  end

  def test_toggle_informant
    o = Object.new
    refute o.informant?
    o.toggle_informant
    assert o.informant?
    refute Object.informant?
    t = Toggle.new
    refute t.informant?
    Toggle.toggle_informant
    assert t.informant?
    assert Toggle.informant?
    t = Toggle.new
    assert t.informant?
    Toggle.toggle_informant
    refute t.informant?
    refute Toggle.informant?
  end
end
