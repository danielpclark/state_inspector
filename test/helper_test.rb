require 'test_helper'

class HelperThing; attr_writer :example end
class HelperThing2; attr_writer :example end
class HelperThing3; attr_writer :example end
class HelperThing4; attr_writer :example end
class HelperThing5; attr_writer :example end
class HelperThing6; attr_writer :example end

class HelperTest < Minitest::Test
  def test_it_scopes_reporter_to_helper_on_toggle_snoop
    refute StateInspector::Reporter.has_observer? HelperThing
    toggle_snoop(HelperThing, InternalObserver.new) do
      assert StateInspector::Reporter.has_observer? HelperThing
    end
    refute StateInspector::Reporter.has_observer? HelperThing
  end

  def test_it_scopes_reporter_to_helper_on_toggle_snoop_clean
    refute StateInspector::Reporter.has_observer? HelperThing2
    toggle_snoop_clean(HelperThing2, InternalObserver.new) do
      assert StateInspector::Reporter.has_observer? HelperThing2
    end
    refute StateInspector::Reporter.has_observer? HelperThing2
  end

  def test_it_restores_original_observer_on_toggle_snoop
    obj = HelperThing3.new
    observer = InternalObserver.new
    StateInspector::Reporter[obj] = observer
    toggle_snoop(obj, InternalObserver.new) do
      refute_equal StateInspector::Reporter[obj], observer
    end
    assert_equal StateInspector::Reporter[obj], observer
  end

  def test_it_restores_original_observer_on_toggle_snoop_clean
    obj = HelperThing4.new
    observer = InternalObserver.new
    StateInspector::Reporter[obj] = observer
    toggle_snoop_clean(obj, InternalObserver.new) do
      refute_equal StateInspector::Reporter[obj], observer
    end
    assert_equal StateInspector::Reporter[obj], observer
  end

  def test_toggle_snoop_blocks_return_value_from_block
    assert_equal 4, toggle_snoop(Object.new) { 4 }
    assert_equal 4, toggle_snoop_clean(Object.new) { 4 }
  end

  def test_toggle_snoop_still_produces_results
    obj = HelperThing5.new
    observer = InternalObserver.new
    StateInspector::Reporter[obj] = observer
    refute obj.class.instance_variable_defined?(:@state_inspector)
    toggle_snoop(obj) do |obsrvr|
      assert_equal [:example=], obj.class.instance_variable_get(:@state_inspector).keys
      obj.example = 4
      assert_equal [[obj, "@example", nil, 4]], obsrvr.values
    end
    assert obj.class.instance_variable_defined?(:@state_inspector)

    # it "test side effect of @state_inspector removal" do
    toggle_snoop_clean(obj) do |obsrvr|
      assert_equal [:example=], obj.class.instance_variable_get(:@state_inspector).keys
      obj.example = 4
      assert_equal [
        [obj, "@example", nil, 4],
        [obj, "@example", 4, 4]
      ], obsrvr.values
    end
    refute obj.class.instance_variable_defined?(:@state_inspector)
    # end

    # it "tests side effect of previous toggle_snoop_clean should remove informer" do
    toggle_snoop_clean(obj) do |obsrvr|
      assert_empty obj.class.instance_variable_get(:@state_inspector).keys

      # there should be nore informing on this method call
      obj.example = 4
      # previous values
      assert_equal [
        [obj, "@example", nil, 4],
        [obj, "@example", 4, 4]
      ], obsrvr.values
    end
    # end
  end

  def test_toggle_snoop_still_produces_results_with_class_of_obj
    obj = HelperThing6.new
    observer = InternalObserver.new
    StateInspector::Reporter[HelperThing6] = observer
    refute obj.class.instance_variable_defined?(:@state_inspector)
    toggle_snoop(HelperThing6) do |obsrvr|
      assert_equal [:example=], obj.class.instance_variable_get(:@state_inspector).keys
      obj.example = 4
      assert_equal [[obj, "@example", nil, 4]], obsrvr.values
    end
    assert obj.class.instance_variable_defined?(:@state_inspector)

    # it "test side effect of @state_inspector removal" do
    toggle_snoop_clean(HelperThing6) do |obsrvr|
      assert_equal [:example=], obj.class.instance_variable_get(:@state_inspector).keys
      obj.example = 4
      assert_equal [
        [obj, "@example", nil, 4],
        [obj, "@example", 4, 4]
      ], obsrvr.values
    end
    refute obj.class.instance_variable_defined?(:@state_inspector)
    # end

    # it "tests side effect of previous toggle_snoop_clean should remove informer" do
    toggle_snoop_clean(HelperThing6) do |obsrvr|
      assert_empty obj.class.instance_variable_get(:@state_inspector).keys

      # there should be no more informing on this method call
      obj.example = 4
      # previous values
      assert_equal [
        [obj, "@example", nil, 4],
        [obj, "@example", 4, 4]
      ], obsrvr.values
    end
    # end
  end
end
