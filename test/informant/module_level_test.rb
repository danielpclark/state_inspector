require 'test_helper'
require 'state_inspector/observers/internal_observer'

module Mlt
  class << self
    attr_writer :a

    def thing= val
      @thing = val
      @side_effect = val.to_s + " asdf"
    end 

    def carp *args
      nil
    end
  end
end

StateInspector::Reporter[Mlt] = StateInspector::Observers::InternalObserver.new

class ModuleLevelTest < Minitest::Test
  def observer; StateInspector::Reporter[Mlt] end
  def teardown; observer.purge end
  def test_adds_hook_to_setter_defined_manually
    m = Mlt
    toggle_snoop(m) do
      m.thing = 42
      assert_empty observer.values

      m.state_inspector.snoop_setters :thing=

      m.thing = :smile
      assert_equal [[m, "@thing", 42, :smile]], observer.values

      assert_equal "smile asdf", m.instance_variable_get(:@side_effect)
    end
  end

  def test_plane_ol_method_call
    m = Mlt
    toggle_snoop(m) do
      m.carp :a, 1, "asdf"
      assert_empty observer.values

      m.state_inspector.snoop_methods :carp

      m.carp :a, 1, "asdf"
      assert_equal [[m, :carp, :a, 1, "asdf"]], observer.values
    end
  end

  def test_it_wont_double_inform_on_an_attr
    m = Mlt
    toggle_snoop(m) do
      m.state_inspector.snoop_setters :a=
      m.a = :speak
      assert_equal [[m, "@a", nil, :speak]], observer.values
    end
  end
end
