require 'test_helper'
require 'state_inspector/observers/internal_observer'

module ModInstLevTest
  attr_writer :a

  def thing= val
    @thing = val
    @side_effect = val.to_s + " asdf"
  end

  def carp *_
    nil
  end

  def self.ui=(other)
    other
  end
end

class Milt
  include ModInstLevTest
end

class ExtIncl
  extend ModInstLevTest
  include ModInstLevTest
end

StateInspector::Reporter[Milt] = StateInspector::Observers::InternalObserver.new
StateInspector::Reporter[ExtIncl] = StateInspector::Observers::InternalObserver.new

class ModuleInstanceLevelTest < Minitest::Test
  def observer; StateInspector::Reporter[Milt] end
  def teardown; observer.purge end
  def test_adds_hook_to_setter_defined_manually
    m = Milt.new
    toggle_snoop(m) do
      m.thing = 42
      assert_equal [[m, "@thing", nil, 42]], observer.values

      m.state_inspector.snoop_setters :thing=

      m.thing = :smile
      assert_equal [
        [m, "@thing", nil, 42],
        [m, "@thing", 42, :smile]
      ], observer.values

      assert_equal "smile asdf", m.instance_variable_get(:@side_effect)
    end
  end

  def test_plane_ol_method_call
    m = Milt.new
    toggle_snoop(m) do
      m.carp :a, 1, "asdf"
      assert_empty observer.values

      m.state_inspector.snoop_methods :carp

      m.carp :a, 1, "asdf"
      assert_equal [[m, :carp, :a, 1, "asdf"]], observer.values
    end
  end

  def test_it_wont_double_inform_on_an_attr
    m = Milt.new
    toggle_snoop(m) do
      m.state_inspector.snoop_setters :a=
      m.a = :speak
      assert_equal [[m, "@a", nil, :speak]], observer.values
    end
  end

  def test_adds_hook_to_setter_defined_manually_with_extend_and_include
    m = ExtIncl.new
    observer = StateInspector::Reporter[ExtIncl]
    toggle_snoop(m) do
      m.thing = 42
      assert_equal [[m, "@thing", nil, 42]], observer.values

      m.state_inspector.snoop_setters :thing=

      m.thing = :smile
      assert_equal [
        [m, "@thing", nil, 42],
        [m, "@thing", 42, :smile]
      ], observer.values

      assert_equal "smile asdf", m.instance_variable_get(:@side_effect)
    end
  ensure
    observer.purge
  end

  def test_plane_ol_method_call_with_extend_and_include
    m = ExtIncl.new
    observer = StateInspector::Reporter[ExtIncl]
    toggle_snoop(m) do
      m.carp :a, 1, "asdf"
      assert_empty observer.values

      m.state_inspector.snoop_methods :carp

      m.carp :a, 1, "asdf"
      assert_equal [[m, :carp, :a, 1, "asdf"]], observer.values
    end
  ensure
    observer.purge
  end

  def test_it_wont_double_inform_on_an_attr_with_extend_and_include
    m = ExtIncl.new
    observer = StateInspector::Reporter[ExtIncl]
    toggle_snoop(m) do
      m.state_inspector.snoop_setters :a=
      m.a = :speak
      assert_equal [[m, "@a", nil, :speak]], observer.values
    end
  ensure
    observer.purge
  end
end
